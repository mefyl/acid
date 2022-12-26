open Base

(** A multi index map is a collection of values with an arbitrary number of
    indexes. *)
module type S = sig
  (** A multi index map. *)
  type t

  (** Values held by a [t] *)
  type value

  (** [all t] is a sequence of all values held by [t]. *)
  val all : t -> value Sequence.t

  (** [add value t] is [t] with [value] added, or [t] if it already contained
      [value]. *)
  val add : value -> t -> t

  (** [empty] is the empty [t] *)
  val empty : t

  val map : t -> f:(value -> value) -> t

  (** [update old new t] is [t] with [old] removed then [new] added. *)
  val update : value -> value -> t -> t

  (** [add value t] is a new multi index with [value] removed from [t], or [t]
      if it did not contain [value]. *)
  val remove : value -> t -> t
end

(** Implementation of an index. *)
module type INDEX = sig
  (** An instance of the index *)
  type t

  (** Indexed values *)
  type value

  (** [add value t] is [t] with value added. *)
  val add : value -> t -> t

  (** [all t] is all the indexed value. *)
  val all : t -> value Sequence.t

  (** [empty] is an empty index. *)
  val empty : t

  (** [is_empty] is whether [t] is empty. *)
  val is_empty : t -> bool

  (** [update old new t] is [t] with [old] removed then [new] added. *)
  val update : value -> value -> t -> t

  (** [remove value t] is [t] with [value] removed. *)
  val remove : value -> t -> t
end

(** A binder binds an index to a specific multi index. *)
module type BINDER = sig
  (** The multi index we bind to. *)
  module Multi_index : S

  (** The bound index type. *)
  type index

  (** [get t] is [t]'s instance of [index] . *)
  val get : Multi_index.t -> index
end

(** Indexes are a set of indexes that can be turned into a multi index. *)
module type INDEXES = sig
  (** An instance of indexes. *)
  type t

  (** Values held by a [t] *)
  type value

  (** [Make (Value)] is a multi index of [Value.t] indexed by all indexes of
      [t]. *)
  module Make (Value : Comparator.S with type t = value) : sig
    (** Internal interoperability functions between index sets. *)
    module Indexes : sig
      (** [add value t] is [t] with [value] added to each individual index. *)
      val add : value -> t Hlist.t -> t Hlist.t

      (** [update old new t] is [t] with [old] removed then [new] added to each
          individual index. *)
      val update : value -> value -> t Hlist.t -> t Hlist.t

      (** [empty] is a set of empty indexes. *)
      val empty : t Hlist.t

      (** [remove value t] is [t] with [value] removed from each individual
          index. *)
      val remove : value -> t Hlist.t -> t Hlist.t
    end

    (** A binder to this set of indexes. *)
    module Bind :
      BINDER with type Multi_index.value = Value.t and type index = t Hlist.t

    (** The multi index with this set of indexes *)
    include
      S with type t = Bind.Multi_index.t and type value = Bind.Multi_index.value
  end
end

(** A type indexable by an extracted property.

    For instance, to index persons by last name:

    {[
      type person = {
        first : string;
        last : string;
      }

      module Ordered_by_lastname :
        ORDERED_BY with type value = person and type t = string = struct
        type value = person

        let get { last; _ } = last

        include String
      end
    ]} *)
module type ORDERED_BY = sig
  (** Ordered values *)
  type value

  (** Type the values are sorted by. *)
  include Comparator.S

  (** [get value] is the [t] to index [value] by. *)
  val get : value -> t
end
