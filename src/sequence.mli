module Step = Base.Sequence.Step

module Make (Monad : Base.Monad.S) : sig
  type 'a t

  val unfold : init:'state -> f:('state -> ('a, 'state) Step.t Monad.t) -> 'a t

  val unfold_step :
    init:'state -> f:('state -> ('a * 'state) option Monad.t) -> 'a t

  val of_list : 'a list -> 'a t

  val concat : 'a t t -> 'a t

  val iter : 'a t -> f:('a -> unit Monad.t) -> unit Monad.t

  val to_list : 'a t -> 'a list Monad.t
end
