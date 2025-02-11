module Step = struct
  (** A sequence step *)
  type ('a, 's) t =
    | Done  (** End of the sequence *)
    | Skip of 's
        (** A step that is a pure monadic action and doesn't yield a new
            sequence element *)
    | Yield of 'a * 's  (** A step that yields a single element *)
    | Yields of 'a list * 's  (** A step that yields several elements *)
end

(** Iterators over a sequence. *)
module type WALKERS2 = sig
  (** The type of the underlying sequence to walk *)
  type ('a, 'b) sequence

  (** The monad underpinning {!sequence} *)
  type ('a, 'b) monad

  (** The return wrapper for the waking functions *)
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

(** 1-parameter version of [WALKERS2] *)
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

(** The type of a sequence over a 2-parameter monad *)
module type S2 = sig
  type ('a, 'b) t

  module M : Monad.S2

  (** Individual sequence steps *)
  module Step : module type of Step

  (** {1 Base sequence operations} *)

  val empty : ('a, 'b) t
  val cons : 'a -> ('a, 'b) t -> ('a, 'b) t
  val head : ('a, 'b) t -> ('a option, 'b) M.t
  val step : ('a, 'b) t -> ('a list * ('a, 'b) t, 'b) M.t

  val unfold :
    init:'state -> f:('state -> (('a, 'state) Step.t, 'b) M.t) -> ('a, 'b) t

  val unfold_step :
    init:'state -> f:('state -> (('a * 'state) option, 'b) M.t) -> ('a, 'b) t

  val concat : (('a, 'b) t, 'b) t -> ('a, 'b) t
  val partition : (('a, 'b) Base.Either.t, 'c) t -> ('a list * 'b list, 'c) M.t
  val length : ('a, 'b) t -> (int, 'b) M.t

  (** {1 Conversions} *)

  val of_base : 'a Base.Sequence.t -> ('a, 'b) t
  val of_list : 'a list -> ('a, 'b) t
  val of_lists : 'a list list -> ('a, 'b) t
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

  (** {1 Traversals} *)

  (** Traversals of the sequence by pure functions *)
  module Pure :
    WALKERS2
      with type ('a, 'b) sequence := ('a, 'b) t
       and type ('a, 'b) monad := ('a, 'b) M.t
       and type ('a, 'b) walk := 'a

  (** @closed *)
  include module type of Pure

  (** Sequential traversals of the sequence by monadic functions *)
  module Seq :
    WALKERS2
      with type ('a, 'b) sequence := ('a, 'b) t
       and type ('a, 'b) monad := ('a, 'b) M.t
       and type ('a, 'b) walk := ('a, 'b) M.t

  (** Parallel monadic traversals of the sequence.

      Parallel here means that the monadic operations don't depend on each
      other, not that they will be scheduled in parallel. *)
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

  (** {1 Memoization} *)

  (** [memoize s] is equivalent to [s], but with the property that any monadic
      operation required to access the elements of [s] will be done at most
      once, even if the sequence is consumed several times. *)
  val memoize : ('a, 'b) t -> ('a, 'b) t

  type 'b unless = { f : 'a. ('a, 'b) M.t -> bool }

  (** [memoize_unless ~f s] is similar to [memoize s], except that only the
      elements of [s] for which [f] returns [true] will be memoized *)
  val memoize_unless : f:'b unless -> ('a, 'b) t -> ('a, 'b) t
end

(** 1-parameter version of [S2] *)
module type S = sig
  (** The type of the sequence *)
  type 'a t

  (** The underlying monad for the sequence *)
  module M : Monad.S

  (** 2-params version of [M], mostly here for internal reasons. [('a, 'e) M2.t]
      is equal to ['a M.t]. *)
  module M2 : sig
    (** @closed *)
    include module type of M with type 'a t := 'a M.t

    type ('a, 'e) t = 'a M.t
  end

  (** @inline *)
  include S2 with type ('a, _) t := 'a t and module M := M2

  (** [memoize_unless ~f s] is similar to [memoize s], except that only the
      elements of [s] for which [f] returns [true] will be memoized *)
  val memoize_unless : f:unit unless -> 'a t -> 'a t

  module Monad : sig
    type nonrec ('a, 'b) map = ('a, unit, 'b, unit) Monad.map

    val map : 'a t -> f:('a, 'b) map -> 'b t
  end
end
