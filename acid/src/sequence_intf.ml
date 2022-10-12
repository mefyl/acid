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
