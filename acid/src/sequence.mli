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

  val to_set :
    (module Base.Comparator.S
       with type comparator_witness = 'witness
        and type t = 'data) ->
    ('data, 'b) t ->
    (('data, 'witness) Base.Set.t, 'b) Monad.t

  val partition :
    (('a, 'b) Base.Either.t, 'c) t -> ('a list * 'b list, 'c) Monad.t

  val head : ('a, 'b) t -> ('a option, 'b) Monad.t
  val length : ('a, 'b) t -> (int, 'b) Monad.t
  val memoize : ('a, 'b) t -> ('a, 'b) t

  type 'b unless = { f : 'a. ('a, 'b) Monad.t -> bool }

  val memoize_unless : f:'b unless -> ('a, 'b) t -> ('a, 'b) t

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

  module Par : sig
    val filter_map :
      ('a, 'b) t -> f:('a -> ('c option, 'b) Monad.t) -> ('c, 'b) t

    val iter : ('a, 'b) t -> f:('a -> (unit, 'b) Monad.t) -> (unit, 'b) Monad.t
    val map : ('a, 'b) t -> f:('a -> ('c, 'b) Monad.t) -> ('c, 'b) t
  end

  module Monad : sig
    type ('a, 'b, 'c, 'd) map = {
      f :
        'state.
        (('a, 'state) Step.t, 'b) Monad.t -> (('c, 'state) Step.t, 'd) Monad.t;
    }

    val map : ('a, 'b) t -> f:('a, 'b, 'c, 'd) map -> ('c, 'd) t
  end
end

module Make (M : Base.Monad.S) : sig
  type 'a t

  include module type of Make2 (struct
      type ('a, 'e) t = 'a M.t

      include (M : Base.Monad.S with type 'a t := 'a M.t)
    end)
    with type ('a, _) t := 'a t

  module Monad : sig
    type nonrec ('a, 'b) map = ('a, unit, 'b, unit) Monad.map

    val map : 'a t -> f:('a, 'b) map -> 'b t
  end

  val memoize_unless : f:unit unless -> 'a t -> 'a t
end
