module type S = sig
  type ('l, 'r) t

  include Select.SPLIT with type ('l, 'r) t := ('l, 'r) t

  val make : 'l -> 'r -> ('l, 'r) t
  val left : 'l -> ('l, _) t option
  val right : 'r -> (_, 'r) t option
  val get : ('l -> 'a) -> ('r -> 'a) -> ('l, 'r) t -> 'a
  val pp : 'a Fmt.t -> 'b Fmt.t -> ('a, 'b) t Fmt.t

  val equal :
    ('a -> 'a -> bool) -> ('b -> 'b -> bool) -> ('a, 'b) t -> ('a, 'b) t -> bool

  val compare :
    ('a -> 'a -> int) -> ('b -> 'b -> int) -> ('a, 'b) t -> ('a, 'b) t -> int
end
