(** Extension of {!Acid.Bench} for the Lwt monad *)

include Acid.Bench
module Lwt = Acid.Bench.Monadic (Lwt_acid)
