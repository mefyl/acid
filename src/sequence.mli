module Step = Base.Sequence.Step

module Make (Monad : Base.Monad.S) : sig
  type 'a t

  module Step = Base.Sequence.Step

  val unfold : init:'state -> f:('state -> ('a, 'state) Step.t Monad.t) -> 'a t

  val unfold_step :
    init:'state -> f:('state -> ('a * 'state) option Monad.t) -> 'a t

  val of_list : 'a list -> 'a t

  val concat : 'a t t -> 'a t

  val iter : 'a t -> f:('a -> unit Monad.t) -> unit Monad.t

  val to_list : 'a t -> 'a list Monad.t

  val step : 'a t -> ('a option * 'a t) Monad.t

  val head : 'a t -> 'a option Monad.t
end

module Make2 (Monad : Base.Monad.S2) : sig
  type ('a, 'b) t

  module Step = Base.Sequence.Step

  val unfold :
    init:'state -> f:('state -> (('a, 'state) Step.t, 'b) Monad.t) -> ('a, 'b) t

  val unfold_step :
    init:'state ->
    f:('state -> (('a * 'state) option, 'b) Monad.t) ->
    ('a, 'b) t

  val of_list : 'a list -> ('a, 'b) t

  val concat : (('a, 'b) t, 'b) t -> ('a, 'b) t

  val iter : ('a, 'b) t -> f:('a -> (unit, 'b) Monad.t) -> (unit, 'b) Monad.t

  val to_list : ('a, 'b) t -> ('a list, 'b) Monad.t

  val step : ('a, 'b) t -> ('a option * ('a, 'b) t, 'b) Monad.t

  val head : ('a, 'b) t -> ('a option, 'b) Monad.t
end
