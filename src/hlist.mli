include module type of Hlist_intf

module Make (T : sig
  type 'a t
end) : S with type 'a value = 'a T.t

module Transduce (From : S) (To : S) : sig
  type mapper = { f : 't. 't From.value -> 't To.value }

  val map : 'a From.t -> f:mapper -> 'a To.t

  type imapper = { f : 't. int -> 't From.value -> 't To.value }

  val mapi : 'a From.t -> f:imapper -> 'a To.t
end

module Make2 (T : sig
  type ('a, 'b) t
end) : S2 with type ('a, 'b) value = ('a, 'b) T.t

module Transduce2 (From : S2) (To : S2) : sig
  type mapper = { f : 'a 'b1 'b2. ('a, 'b1) From.value -> ('a, 'b2) To.value }

  val map : ('a, 'b) From.t -> f:mapper -> ('a, 'b) To.t

  type imapper = {
    f : 'a 'b1 'b2. int -> ('a, 'b1) From.value -> ('a, 'b2) To.value;
  }

  val mapi : ('a, 'b) From.t -> f:imapper -> ('a, 'b) To.t
end

module Transduce_2 (From : S) (To : S2) : sig
  type mapper = { f : 'a 'b. 'a From.value -> ('a, 'b) To.value }

  val map : 'a From.t -> f:mapper -> ('a, 'b) To.t

  type imapper = { f : 'a 'b. int -> 'a From.value -> ('a, 'b) To.value }

  val mapi : 'a From.t -> f:imapper -> ('a, 'b) To.t
end

include module type of Make (struct
  type 'a t = 'a
end)

val to_pairs : 'l t -> 'l
