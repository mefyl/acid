type ('a, 'b) desc = 'a * 'b

module type S2 = sig
  type ('t, 'tag) value

  type ('t, 'tag) t =
    | ( :: ) : ('hd, 'tag) value * ('tl, 'tag) t -> (('hd, 'tl) desc, 'tag) t
    | [] : (unit, 'tag) t

  val length : _ t -> int

  type 'res mapper = { f : 't 'tag. ('t, 'tag) value -> 'res }

  type 'res imapper = { f : 't 'tag. int -> ('t, 'tag) value -> 'res }

  val iter : ('t, 'tag) t -> f:unit mapper -> unit

  val map : ('t, 'tag) t -> f:'res mapper -> 'res list

  val filter_map : ('t, 'tag) t -> f:'res option mapper -> 'res list

  val iteri : ('t, 'tag) t -> f:unit imapper -> unit

  val mapi : ('t, 'tag) t -> f:'res imapper -> 'res list

  val filter_mapi : ('t, 'tag) t -> f:'res option imapper -> 'res list
end

module type S = sig
  type 't value

  type 't t =
    | ( :: ) : 'hd value * 'tl t -> ('hd, 'tl) desc t
    | [] : unit t

  val length : _ t -> int

  type 'res mapper = { f : 't 'tag. 't value -> 'res }

  type 'res imapper = { f : 't 'tag. int -> 't value -> 'res }

  val iter : 't t -> f:unit mapper -> unit

  val map : 't t -> f:'res mapper -> 'res list

  val filter_map : 't t -> f:'res option mapper -> 'res list

  val iteri : 't t -> f:unit imapper -> unit

  val mapi : 't t -> f:'res imapper -> 'res list

  val filter_mapi : 't t -> f:'res option imapper -> 'res list
end
