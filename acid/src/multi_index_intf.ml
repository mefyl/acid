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
  val empty : t
  val is_empty : t -> bool
  val update : value -> value -> t -> t
  val remove : value -> t -> t
end

module type BINDER = sig
  type t
  type index

  val get : t -> index
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

    include S with type value = Value.t
    module Bind : BINDER with type t = t and type index = indexes Hlist.t
  end
end

module type ORDERED_BY = sig
  include Comparator.S

  type value

  val get : value -> t
end
