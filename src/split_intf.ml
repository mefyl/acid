module type S = sig
  type ('l, 'r) t

  type ('l, 'r) js

  val case : 'a -> 'a -> 'a

  val make : 'l -> 'r -> ('l, 'r) t

  val left : 'l -> ('l, _) t option

  val right : 'r -> (_, 'r) t option

  val get : ('l -> 'a) -> ('r -> 'a) -> ('l, 'r) t -> 'a

  val schema :
    'r Schematic.schema -> 'w Schematic.schema -> ('r, 'w) t Schematic.schema
end
