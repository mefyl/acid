(** Heterogeneous lists. *)

include module type of Hlist_intf

module Make (T : sig
  type 'a t
end) : S with type 'a value = 'a T.t

module Make2 (T : sig
  type ('a, 'b) t
end) : S2 with type ('a, 'b) value = ('a, 'b) T.t

include module type of Make (struct
  type 'a t = 'a
end)

val to_pairs : 'l t -> 'l
