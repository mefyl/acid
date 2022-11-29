open Base

module type S = sig
  type t
  type value

  val add : value -> t -> t
  val empty : t
  val remove : value -> t -> t
end

module type INDEX = sig
  type t
  type value

  val add : value -> t -> t
  val all : t -> value Sequence.t
  val empty : t
  val is_empty : t -> bool
  val update : value -> value -> t -> t
  val remove : value -> t -> t
end

module type BINDER = sig
  module Multi_index : S

  type index

  val get : Multi_index.t -> index
end

module type INDEXES = sig
  type t
  type value

  module Make (Value : Comparator.S with type t = value) : sig
    module Indexes : sig
      val add : value -> t Hlist.t -> t Hlist.t
      val empty : t Hlist.t
      val remove : value -> t Hlist.t -> t Hlist.t
    end

    type indexes = t

    module Bind :
      BINDER
        with type Multi_index.value = Value.t
         and type index = indexes Hlist.t

    include module type of Bind.Multi_index
  end
end

module type ORDERED_BY = sig
  include Comparator.S

  type value

  val get : value -> t
end
