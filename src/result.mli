(** Convenience extensions on top of {!Base.Result}. *)

(** @closed *)
include module type of Base.Result

val both : ('a, 'e) t -> ('b, 'e) t -> ('a * 'b, 'e) t

val to_option : ('a, _) t -> 'a option

module Nest (M : Monad.S) : Monad.S2 with type ('a, 'b) t = ('a, 'b) t M.t
