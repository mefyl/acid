include module type of Hlist_intf

val length : 'l t -> int

module Make (T : sig
  type 'a t
end) : S with type 'a value = 'a T.t

module Transduce (From : S) (To : S) : sig
  type mapper = { f : 't. 't From.value -> 't To.value }

  val map : 'a From.t -> f:mapper -> 'a To.t
end

module Make2 (T : sig
  type ('a, 'b) t
end) : S2 with type ('a, 'b) value = ('a, 'b) T.t

module Transduce2 (From : S2) (To : S2) : sig
  type mapper = { f : 't 'tag. ('t, 'tag) From.value -> ('t, 'tag) To.value }

  val map : ('a, 'b) From.t -> f:mapper -> ('a, 'b) To.t
end

module Transduce_2 (From : S) (To : S2) : sig
  type mapper = { f : 't 'tag. 't From.value -> ('t, 'tag) To.value }

  val map : 'a From.t -> f:mapper -> ('a, 'b) To.t
end
