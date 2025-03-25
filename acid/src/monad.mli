include module type of Monad_intf
module MakeNestable (M : BASIC_NESTABLE) : NESTABLE with type 'a t = 'a M.t

module MakeNestable2 (M : BASIC_NESTABLE2) :
  NESTABLE2 with type ('a, 'b) t = ('a, 'b) M.t

module State : sig
  module Make (State : sig
    type t
  end) : S with type 'a t = State.t -> 'a * State.t
end
