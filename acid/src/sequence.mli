include module type of Sequence_intf.V0_11_11
module Make (Monad : Monad.S) : S with module M = Monad
module Make2 (Monad : Monad.S2) : S2 with module M = Monad
