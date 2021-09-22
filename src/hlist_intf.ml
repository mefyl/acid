type _ t =
  | ( :: ) : 'a * 'b t -> ('a -> 'b) t
  | [] : unit t

module type S2 = sig
  type ('t, 'tag) value

  type ('t, 'tag) t =
    | ( :: ) : ('hd, 'tag) value * ('tl, 'tag) t -> ('hd -> 'tl, 'tag) t
    | [] : (unit, 'tag) t

  val length : _ t -> int

  type 'res mapper = { f : 't 'tag. ('t, 'tag) value -> 'res option }

  val map : ('t, 'tag) t -> f:'res mapper -> 'res list
end

module type S = sig
  type 't value

  type 't t =
    | ( :: ) : 'hd value * 'tl t -> ('hd -> 'tl) t
    | [] : unit t

  val length : _ t -> int

  type 'res mapper = { f : 't 'tag. 't value -> 'res option }

  val map : 't t -> f:'res mapper -> 'res list
end
