include module type of Monad_intf
module MakeNestable (M : BASIC_NESTABLE) : NESTABLE with type 'a t = 'a M.t

module MakeNestable2 (M : BASIC_NESTABLE2) :
  NESTABLE2 with type ('a, 'b) t = ('a, 'b) M.t

module State : sig
  module Make (State : sig
    type t
  end) : S with type 'a t = State.t -> 'a * State.t
end

module Make (X : Basic) : S with type 'a t := 'a X.t
module Make2 (X : Basic2) : S2 with type ('a, 'b) t := ('a, 'b) X.t
module Make3 (X : Basic3) : S3 with type ('a, 'b, 'c) t := ('a, 'b, 'c) X.t
