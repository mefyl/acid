module type S = sig
  type 'a t

  include Select_schema.MODE with type 'a t := 'a t
  include Select_jsoo.MODE with type 'a t := 'a t

  val return : 'a -> 'a t
  val map : ('a -> 'b) -> 'a t -> 'b t
  val get : 'a t -> 'a option
  val default : 'a -> 'a t
  val if_optional : 'a option -> 'a t option
  val pp : 'a Fmt.t -> 'a t Fmt.t
  val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool
  val compare : ('a -> 'a -> int) -> 'a t -> 'a t -> int

  module Switch : sig
    type ('r, 'w) t

    include Select_schema.SWITCH with type ('r, 'w) t := ('r, 'w) t
    include Select_jsoo.SWITCH with type ('r, 'w) t := ('r, 'w) t

    val switch : 'r -> 'w -> ('r, 'w) t
    val map : ('r -> 'rr) -> ('w -> 'ww) -> ('r, 'w) t -> ('rr, 'ww) t
  end
end
