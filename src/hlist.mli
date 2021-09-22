include module type of Hlist_intf

val length : 'l t -> int

module Make (T : sig
  type 'a t
end) : S with type 'a value = 'a T.t

module Make2 (T : sig
  type ('a, 'b) t
end) : S2 with type ('a, 'b) value = ('a, 'b) T.t
