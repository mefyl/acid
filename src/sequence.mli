include module type of Sequence_intf

module Make (Monad : Base.Monad.S) : sig
  type 'a t

  module Step = Step

  val empty : 'a t
  val unfold : init:'state -> f:('state -> ('a, 'state) Step.t Monad.t) -> 'a t

  val unfold_step :
    init:'state -> f:('state -> ('a * 'state) option Monad.t) -> 'a t

  val of_base : 'a Base.Sequence.t -> 'a t
  val of_list : 'a list -> 'a t
  val concat : 'a t t -> 'a t
  val to_list : 'a t -> 'a list Monad.t
  val to_list_rev : 'a t -> 'a list Monad.t
  val partition : ('a, 'b) Base.Either.t t -> ('a list * 'b list) Monad.t
  val head : 'a t -> 'a option Monad.t
  val length : 'a t -> int Monad.t

  include
    WALKERS
      with type 'a sequence := 'a t
       and type 'a monad := 'a Monad.t
       and type 'a walk := 'a

  module Seq :
    WALKERS
      with type 'a sequence := 'a t
       and type 'a monad := 'a Monad.t
       and type 'a walk := 'a Monad.t
end

module Make2 (Monad : Base.Monad.S2) : sig
  type ('a, 'b) t

  module Step = Step

  val empty : ('a, 'b) t

  val unfold :
    init:'state -> f:('state -> (('a, 'state) Step.t, 'b) Monad.t) -> ('a, 'b) t

  val unfold_step :
    init:'state ->
    f:('state -> (('a * 'state) option, 'b) Monad.t) ->
    ('a, 'b) t

  val of_base : 'a Base.Sequence.t -> ('a, 'b) t
  val of_list : 'a list -> ('a, 'b) t
  val concat : (('a, 'b) t, 'b) t -> ('a, 'b) t
  val to_list : ('a, 'b) t -> ('a list, 'b) Monad.t

  val partition :
    (('a, 'b) Base.Either.t, 'c) t -> ('a list * 'b list, 'c) Monad.t

  val head : ('a, 'b) t -> ('a option, 'b) Monad.t
  val length : ('a, 'b) t -> (int, 'b) Monad.t

  include
    WALKERS2
      with type ('a, 'b) sequence := ('a, 'b) t
       and type ('a, 'b) monad := ('a, 'b) Monad.t
       and type ('a, 'b) walk := 'a

  module Seq :
    WALKERS2
      with type ('a, 'b) sequence := ('a, 'b) t
       and type ('a, 'b) monad := ('a, 'b) Monad.t
       and type ('a, 'b) walk := ('a, 'b) Monad.t
end
