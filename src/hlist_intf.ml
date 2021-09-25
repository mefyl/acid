type ('a, 'b) desc = 'a * 'b

module type S2 = sig
  type ('a, 'b) value

  type ('a, 'b) t =
    | ( :: ) : ('hd, 'b) value * ('tl, 'b) t -> (('hd, 'tl) desc, 'b) t
    | [] : (unit, 'b) t

  val length : _ t -> int

  type 'res mapper = { f : 'a 'b. ('a, 'b) value -> 'res }

  type 'res imapper = { f : 'a 'b. int -> ('a, 'b) value -> 'res }

  val iter : ('a, 'b) t -> f:unit mapper -> unit

  val map : ('a, 'b) t -> f:'res mapper -> 'res list

  val filter_map : ('a, 'b) t -> f:'res option mapper -> 'res list

  val iteri : ('a, 'b) t -> f:unit imapper -> unit

  val mapi : ('a, 'b) t -> f:'res imapper -> 'res list

  val filter_mapi : ('a, 'b) t -> f:'res option imapper -> 'res list
end

module type S = sig
  type 'a value

  type 'a t =
    | ( :: ) : 'hd value * 'tl t -> ('hd, 'tl) desc t
    | [] : unit t

  val length : _ t -> int

  type 'res mapper = { f : 'a. 'a value -> 'res }

  type 'res imapper = { f : 'a. int -> 'a value -> 'res }

  val iter : 'a t -> f:unit mapper -> unit

  val map : 'a t -> f:'res mapper -> 'res list

  val filter_map : 'a t -> f:'res option mapper -> 'res list

  val iteri : 'a t -> f:unit imapper -> unit

  val mapi : 'a t -> f:'res imapper -> 'res list

  val filter_mapi : 'a t -> f:'res option imapper -> 'res list
end
