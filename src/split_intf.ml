module type S = sig
  type ('l, 'r) t

  include Select.SPLIT with type ('l, 'r) t := ('l, 'r) t

  val case : 'a -> 'a -> 'a

  val make : 'l -> 'r -> ('l, 'r) t

  val left : 'l -> ('l, _) t option

  val right : 'r -> (_, 'r) t option

  val get : ('l -> 'a) -> ('r -> 'a) -> ('l, 'r) t -> 'a
end
