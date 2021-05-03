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

  val find : 'a t -> f:('a -> bool Monad.t) -> 'a option Monad.t
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

  val filter : ('a, 'c) t -> f:('a -> (bool, 'c) Monad.t) -> ('a, 'c) t

  val filter_map : ('a, 'c) t -> f:('a -> ('b option, 'c) Monad.t) -> ('b, 'c) t

  val map : ('a, 'c) t -> f:('a -> ('b, 'c) Monad.t) -> ('b, 'c) t

  val fold_left :
    ('a, 'b) t ->
    f:('c -> 'a -> ('c, 'b) Monad.t) ->
    init:'c ->
    ('c, 'b) Monad.t

  val iter : ('a, 'b) t -> f:('a -> (unit, 'b) Monad.t) -> (unit, 'b) Monad.t

  val to_list : ('a, 'b) t -> ('a list, 'b) Monad.t

  val step : ('a, 'b) t -> ('a option * ('a, 'b) t, 'b) Monad.t

  val head : ('a, 'b) t -> ('a option, 'b) Monad.t

  val find_map :
    ('a, 'b) t -> f:('a -> ('c option, 'b) Monad.t) -> ('c option, 'b) Monad.t

  val find :
    ('a, 'b) t -> f:('a -> (bool, 'b) Monad.t) -> ('a option, 'b) Monad.t
end
