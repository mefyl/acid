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
  val iter : 'a t -> f:('a -> unit Monad.t) -> unit Monad.t
  val to_list : 'a t -> 'a list Monad.t
  val to_list_rev : 'a t -> 'a list Monad.t
  val partition : ('a, 'b) Base.Either.t t -> ('a list * 'b list) Monad.t
  val head : 'a t -> 'a option Monad.t
  val find : 'a t -> f:('a -> bool Monad.t) -> 'a option Monad.t

  val fold :
    'a t -> init:'state -> f:('state -> 'a -> 'state Monad.t) -> 'state Monad.t

  val fold_until :
    'a t ->
    init:'accum ->
    f:
      ('accum ->
      'a ->
      ('accum, 'final) Base.Container.Continue_or_stop.t Monad.t) ->
    finish:('accum -> 'final) ->
    'final Monad.t

  val length : 'a t -> int Monad.t
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
  val filter : ('a, 'c) t -> f:('a -> (bool, 'c) Monad.t) -> ('a, 'c) t
  val filter_map : ('a, 'c) t -> f:('a -> ('b option, 'c) Monad.t) -> ('b, 'c) t
  val map : ('a, 'c) t -> f:('a -> ('b, 'c) Monad.t) -> ('b, 'c) t
  val iter : ('a, 'b) t -> f:('a -> (unit, 'b) Monad.t) -> (unit, 'b) Monad.t
  val to_list : ('a, 'b) t -> ('a list, 'b) Monad.t

  val partition :
    (('a, 'b) Base.Either.t, 'c) t -> ('a list * 'b list, 'c) Monad.t

  val head : ('a, 'b) t -> ('a option, 'b) Monad.t

  val find_map :
    ('a, 'b) t -> f:('a -> ('c option, 'b) Monad.t) -> ('c option, 'b) Monad.t

  val find :
    ('a, 'b) t -> f:('a -> (bool, 'b) Monad.t) -> ('a option, 'b) Monad.t

  val fold :
    ('a, 'b) t ->
    init:'c ->
    f:('c -> 'a -> ('c, 'b) Monad.t) ->
    ('c, 'b) Monad.t

  val fold_until :
    ('a, 'b) t ->
    init:'accum ->
    f:
      ('accum ->
      'a ->
      (('accum, 'final) Base.Container.Continue_or_stop.t, 'b) Monad.t) ->
    finish:('accum -> 'final) ->
    ('final, 'b) Monad.t

  val length : ('a, 'b) t -> (int, 'b) Monad.t
end
