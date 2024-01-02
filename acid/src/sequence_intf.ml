module Step = struct
  type ('a, 's) t =
    | Done
    | Skip of 's
    | Yield of 'a * 's
    | Yields of 'a list * 's
end

module type WALKERS2 = sig
  type ('a, 'b) sequence
  type ('a, 'b) monad
  type ('a, 'b) walk

  val filter :
    ('a, 'c) sequence -> f:('a -> (bool, 'c) walk) -> ('a, 'c) sequence

  val filter_map :
    ('a, 'c) sequence -> f:('a -> ('b option, 'c) walk) -> ('b, 'c) sequence

  val folding_filter_map :
    ('a, 'c) sequence ->
    init:'fold ->
    f:('fold -> 'a -> ('fold * 'b option, 'c) walk) ->
    ('b, 'c) sequence

  val folding_map :
    ('a, 'c) sequence ->
    init:'fold ->
    f:('fold -> 'a -> ('fold * 'b, 'c) walk) ->
    ('b, 'c) sequence

  val map : ('a, 'c) sequence -> f:('a -> ('b, 'c) walk) -> ('b, 'c) sequence
  val iter : ('a, 'b) sequence -> f:('a -> (unit, 'b) walk) -> (unit, 'b) monad

  val find_map :
    ('a, 'b) sequence -> f:('a -> ('c option, 'b) walk) -> ('c option, 'b) monad

  val find :
    ('a, 'b) sequence -> f:('a -> (bool, 'b) walk) -> ('a option, 'b) monad

  val fold :
    ('a, 'b) sequence ->
    init:'c ->
    f:('c -> 'a -> ('c, 'b) walk) ->
    ('c, 'b) monad

  val fold_until :
    ('a, 'b) sequence ->
    init:'accum ->
    f:
      ('accum ->
      'a ->
      (('accum, 'final) Base.Container.Continue_or_stop.t, 'b) walk) ->
    finish:('accum -> 'final) ->
    ('final, 'b) monad

  val group_fold :
    ('a, 'b) sequence ->
    init:('a -> ('c, 'b) walk) ->
    f:('c -> 'a -> ('c option, 'b) walk) ->
    ('c, 'b) sequence
end

module type WALKERS = sig
  type 'a sequence
  type 'a monad
  type 'a walk

  include
    WALKERS2
      with type ('a, _) sequence := 'a sequence
       and type ('a, _) monad := 'a monad
       and type ('a, _) walk := 'a walk
end

module type S2 = sig
  type ('a, 'b) t

  module M : Monad.S2
  module Step : module type of Step

  val empty : ('a, 'b) t
  val cons : 'a -> ('a, 'b) t -> ('a, 'b) t

  val unfold :
    init:'state -> f:('state -> (('a, 'state) Step.t, 'b) M.t) -> ('a, 'b) t

  val unfold_step :
    init:'state -> f:('state -> (('a * 'state) option, 'b) M.t) -> ('a, 'b) t

  val step : ('a, 'b) t -> ('a list * ('a, 'b) t, 'b) M.t
  val of_base : 'a Base.Sequence.t -> ('a, 'b) t
  val of_list : 'a list -> ('a, 'b) t
  val of_lists : 'a list list -> ('a, 'b) t
  val concat : (('a, 'b) t, 'b) t -> ('a, 'b) t
  val to_list : ('a, 'b) t -> ('a list, 'b) M.t
  val to_list_rev : ('a, 'b) t -> ('a list, 'b) M.t

  val to_map :
    (module Base.Comparator.S
       with type comparator_witness = 'witness
        and type t = 'key) ->
    ('key * 'data, 'b) t ->
    (('key, 'data, 'witness) Base.Map.t, 'b) M.t

  val to_set :
    (module Base.Comparator.S
       with type comparator_witness = 'witness
        and type t = 'data) ->
    ('data, 'b) t ->
    (('data, 'witness) Base.Set.t, 'b) M.t

  val partition : (('a, 'b) Base.Either.t, 'c) t -> ('a list * 'b list, 'c) M.t
  val head : ('a, 'b) t -> ('a option, 'b) M.t
  val length : ('a, 'b) t -> (int, 'b) M.t
  val memoize : ('a, 'b) t -> ('a, 'b) t

  type 'b unless = { f : 'a. ('a, 'b) M.t -> bool }

  val memoize_unless : f:'b unless -> ('a, 'b) t -> ('a, 'b) t

  include
    WALKERS2
      with type ('a, 'b) sequence := ('a, 'b) t
       and type ('a, 'b) monad := ('a, 'b) M.t
       and type ('a, 'b) walk := 'a

  module Seq :
    WALKERS2
      with type ('a, 'b) sequence := ('a, 'b) t
       and type ('a, 'b) monad := ('a, 'b) M.t
       and type ('a, 'b) walk := ('a, 'b) M.t

  module Par : sig
    val filter_map : ('a, 'b) t -> f:('a -> ('c option, 'b) M.t) -> ('c, 'b) t
    val iter : ('a, 'b) t -> f:('a -> (unit, 'b) M.t) -> (unit, 'b) M.t
    val map : ('a, 'b) t -> f:('a -> ('c, 'b) M.t) -> ('c, 'b) t
  end

  module Monad : sig
    type ('a, 'b, 'c, 'd) map = {
      f : 'state. (('a, 'state) Step.t, 'b) M.t -> (('c, 'state) Step.t, 'd) M.t;
    }

    val map : ('a, 'b) t -> f:('a, 'b, 'c, 'd) map -> ('c, 'd) t
  end
end

module type S = sig
  type 'a t

  module M : Monad.S

  module M2 : sig
    include module type of M with type 'a t := 'a M.t

    type ('a, 'e) t = 'a M.t
  end

  include S2 with type ('a, _) t := 'a t and module M := M2

  module Monad : sig
    type nonrec ('a, 'b) map = ('a, unit, 'b, unit) Monad.map

    val map : 'a t -> f:('a, 'b) map -> 'b t
  end

  val memoize_unless : f:unit unless -> 'a t -> 'a t
end
