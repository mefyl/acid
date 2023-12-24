[%%metapackage metaversion]

[%%metadef
open Metaversion

let interface version =
  Sig.make
    [%sig:
      include module type of Let_intf.V0_11_11

      module Syntax2 (M : Monad.S2) :
        S2
          with type ('a, 'b) t := ('a, 'b) M.t
           and type 'a option := 'a Option.t
           and type ('a, 'b) result := ('a, 'b) Result.t

      module Syntax (M : Monad.S) :
        S
          with type 'a t := 'a M.t
           and type 'a option := 'a Option.t
           and type ('a, 'b) result := ('a, 'b) Result.t

      module Syntax2_suffixes
          (M : Monad.S2)
          (Option : Monad.NESTABLE)
          (Result : Monad.NESTABLE2) :
        S2
          with type ('a, 'b) t := ('a, 'b) M.t
           and type 'a option := 'a Option.t
           and type ('a, 'b) result := ('a, 'b) Result.t

      module Syntax_suffixes
          (M : Monad.S)
          (Option : Monad.NESTABLE)
          (Result : Monad.NESTABLE2) :
        S
          with type 'a t := 'a M.t
           and type 'a option := 'a Option.t
           and type ('a, 'b) result := ('a, 'b) Result.t]]

module type V0_11_0 = [%meta interface (Version.make 0 11 0)]
module type V0_11_11 = [%meta interface (Version.make 0 11 11)]
