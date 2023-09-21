type t

val make : ?name:string -> unit -> t

(** {1. Reading} *)

val lock_read : t -> unit Lwt.t
val release_read : t -> unit
val read : t -> ?reason:string -> (unit -> 'a Lwt.t) -> 'a Lwt.t

(** {1. Writing} *)

val lock_write : t -> unit Lwt.t
val release_write : t -> unit
val write : t -> ?reason:string -> (unit -> 'a Lwt.t) -> 'a Lwt.t

(** {1. State} *)

type state =
  | Free
  | Reading of int
  | Writing
[@@deriving show]

val state : t -> state
