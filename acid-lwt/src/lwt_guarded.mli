(** A ['a t] holds a ['a] and ensures only one thread of execution can access it
    at any time. *)
type 'a t

(** [make v] is a [t] that holds [v]. *)
val make : 'a -> 'a t

(** [acquire t ~f] is [f v] where [v] is the value held by [t].

    It ensures that only one such concurrent invocation exists at any point in
    time. *)
val acquire : 'a t -> f:('a -> 'b Lwt.t) -> 'b Lwt.t

(** [is_empty t] is whether there are any thread blocked waiting for [t]. *)
val is_empty : _ t -> bool

(** [is_empty t] is whether there are any thread currently locking [t]. *)
val is_locked : _ t -> bool
