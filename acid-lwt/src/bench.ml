(** Extension of {!Acid.Bench} for the Lwt monad *)

module Lwt = Acid.Bench.Monadic (Lwt_acid)
include Lwt
module Pure = Acid.Bench
