(** Convenience extensions on top of {!Base.Array}. *)

(** @closed *)
include Base.Either

let pp first second fmt = function
  | First v -> first fmt v
  | Second v -> second fmt v

include Select.Either
