include module type of Let_intf

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
     and type ('a, 'b) result := ('a, 'b) Result.t
