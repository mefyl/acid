(** Convenience extensions on top of {!Base.Array}. *)

(** @closed *)
include module type of Base.Either

val pp : 'first Fmt.t -> 'second Fmt.t -> ('first, 'second) t Fmt.t

include module type of Select_schema.Either
include module type of Select_jsoo.Either
