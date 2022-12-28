include module type of Sequence_intf

module Make2 (Monad : Base.Monad.S2) : sig
  type ('a, 'b) t

  module Step = Step

  val empty : ('a, 'b) t
  val cons : 'a -> ('a, 'b) t -> ('a, 'b) t

  val unfold :
    init:'state -> f:('state -> (('a, 'state) Step.t, 'b) Monad.t) -> ('a, 'b) t

  val unfold_step :
    init:'state ->
    f:('state -> (('a * 'state) option, 'b) Monad.t) ->
    ('a, 'b) t

  val step : ('a, 'b) t -> ('a list * ('a, 'b) t, 'b) Monad.t
  val of_base : 'a Base.Sequence.t -> ('a, 'b) t
  val of_list : 'a list -> ('a, 'b) t
  val of_lists : 'a list list -> ('a, 'b) t
  val concat : (('a, 'b) t, 'b) t -> ('a, 'b) t
  val to_list : ('a, 'b) t -> ('a list, 'b) Monad.t
  val to_list_rev : ('a, 'b) t -> ('a list, 'b) Monad.t

  val to_map :
    (module Base.Comparator.S
       with type comparator_witness = 'witness
        and type t = 'key) ->
    ('key * 'data, 'b) t ->
    (('key, 'data, 'witness) Base.Map.t, 'b) Monad.t

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

module Make (Monad : Base.Monad.S) : sig
  type 'a t

  include module type of Make2 (struct
      type ('a, 'e) t = 'a Monad.t

      include (Monad : Base.Monad.S with type 'a t := 'a Monad.t)
    end)
    with type ('a, _) t := 'a t
end
