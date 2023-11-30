module type S2 = sig
  type ('a, 'b) t
  type 'a option
  type ('a, 'b) result

  val ( >>= ) : ('a, 'b) t -> ('a -> ('c, 'b) t) -> ('c, 'b) t
  val ( >>| ) : ('a, 'b) t -> ('a -> 'c) -> ('c, 'b) t
  val ( let* ) : ('a, 'b) t -> ('a -> ('c, 'b) t) -> ('c, 'b) t
  val ( let+ ) : ('a, 'b) t -> ('a -> 'c) -> ('c, 'b) t
  val ( and* ) : ('a, 'b) t -> ('c, 'b) t -> ('a * 'c, 'b) t
  val ( and+ ) : ('a, 'b) t -> ('c, 'b) t -> ('a * 'c, 'b) t

  (* Nested option operators *)

  val ( >>=? ) :
    ('a option, 'b) t -> ('a -> ('c option, 'b) t) -> ('c option, 'b) t

  val ( let*? ) :
    ('a option, 'b) t -> ('a -> ('c option, 'b) t) -> ('c option, 'b) t

  val ( and*? ) :
    ('a option, 'b) t -> ('c option, 'b) t -> (('a * 'c) option, 'b) t

  val ( >>|? ) : ('a option, 'b) t -> ('a -> 'c) -> ('c option, 'b) t
  val ( let+? ) : ('a option, 'b) t -> ('a -> 'c) -> ('c option, 'b) t

  val ( and+? ) :
    ('a option, 'b) t -> ('c option, 'b) t -> (('a * 'c) option, 'b) t

  (* Nested result operators *)

  val ( >>=! ) :
    (('a, 'b) result, 'b) t ->
    ('a -> (('c, 'b) result, 'b) t) ->
    (('c, 'b) result, 'b) t

  val ( let*! ) :
    (('a, 'b) result, 'b) t ->
    ('a -> (('c, 'b) result, 'b) t) ->
    (('c, 'b) result, 'b) t

  val ( and*! ) :
    (('a, 'b) result, 'b) t ->
    (('c, 'b) result, 'b) t ->
    (('a * 'c, 'b) result, 'b) t

  val ( >>|! ) :
    (('a, 'b) result, 'b) t -> ('a -> 'c) -> (('c, 'b) result, 'b) t

  val ( let+! ) :
    (('a, 'b) result, 'b) t -> ('a -> 'c) -> (('c, 'b) result, 'b) t

  val ( and+! ) :
    (('a, 'b) result, 'b) t ->
    (('c, 'b) result, 'b) t ->
    (('a * 'c, 'b) result, 'b) t

  (* Nested option result operators *)

  val ( >>=!? ) :
    (('a option, 'b) result, 'b) t ->
    ('a -> (('c option, 'b) result, 'b) t) ->
    (('c option, 'b) result, 'b) t

  val ( let*!? ) :
    (('a option, 'b) result, 'b) t ->
    ('a -> (('c option, 'b) result, 'b) t) ->
    (('c option, 'b) result, 'b) t

  val ( and*!? ) :
    (('a option, 'b) result, 'b) t ->
    (('c option, 'b) result, 'b) t ->
    ((('a * 'c) option, 'b) result, 'b) t

  val ( >>|!? ) :
    (('a option, 'b) result, 'b) t ->
    ('a -> 'c) ->
    (('c option, 'b) result, 'b) t

  val ( let+!? ) :
    (('a option, 'b) result, 'b) t ->
    ('a -> 'c) ->
    (('c option, 'b) result, 'b) t

  val ( and+!? ) :
    (('a option, 'b) result, 'b) t ->
    (('c option, 'b) result, 'b) t ->
    ((('a * 'c) option, 'b) result, 'b) t

  (* Option operators *)

  val ( >>=?? ) :
    ('a, 'b) t Base.Option.t -> ('a Base.Option.t -> ('c, 'b) t) -> ('c, 'b) t

  val ( let*?? ) :
    ('a, 'b) t Base.Option.t -> ('a Base.Option.t -> ('c, 'b) t) -> ('c, 'b) t

  val ( >>|?? ) :
    ('a, 'b) t Base.Option.t -> ('a Base.Option.t -> 'c) -> ('c, 'b) t

  val ( let+?? ) :
    ('a, 'b) t Base.Option.t -> ('a Base.Option.t -> 'c) -> ('c, 'b) t

  val ( >>=??! ) :
    (('a, 'b) result, 'b) t Base.Option.t ->
    ('a Base.Option.t -> (('c, 'b) result, 'b) t) ->
    (('c, 'b) result, 'b) t

  val ( let*??! ) :
    (('a, 'b) result, 'b) t Base.Option.t ->
    ('a Base.Option.t -> (('c, 'b) result, 'b) t) ->
    (('c, 'b) result, 'b) t

  val ( >>|??! ) :
    (('a, 'b) result, 'b) t Base.Option.t ->
    ('a Base.Option.t -> 'c) ->
    (('c, 'b) result, 'b) t

  val ( let+??! ) :
    (('a, 'b) result, 'b) t Base.Option.t ->
    ('a Base.Option.t -> 'c) ->
    (('c, 'b) result, 'b) t

  (* Result operators *)

  val ( >>=!! ) :
    (('a, 'b) t, 'b) Base.Result.t ->
    (('a, 'b) Base.Result.t -> ('c, 'b) t) ->
    ('c, 'b) t

  val ( let*!! ) :
    (('a, 'b) t, 'b) Base.Result.t ->
    (('a, 'b) Base.Result.t -> ('c, 'b) t) ->
    ('c, 'b) t

  val ( >>|!! ) :
    (('a, 'b) t, 'b) Base.Result.t ->
    (('a, 'b) Base.Result.t -> 'c) ->
    ('c, 'b) t

  val ( let+!! ) :
    (('a, 'b) t, 'b) Base.Result.t ->
    (('a, 'b) Base.Result.t -> 'c) ->
    ('c, 'b) t

  val ( >>=!!? ) :
    (('a option, 'b) t, 'b) Base.Result.t ->
    (('a, 'b) Base.Result.t -> ('c option, 'b) t) ->
    ('c option, 'b) t

  val ( let*!!? ) :
    (('a option, 'b) t, 'b) Base.Result.t ->
    (('a, 'b) Base.Result.t -> ('c option, 'b) t) ->
    ('c option, 'b) t

  val ( >>|!!? ) :
    (('a option, 'b) t, 'b) Base.Result.t ->
    (('a, 'b) Base.Result.t -> 'c) ->
    ('c option, 'b) t

  val ( let+!!? ) :
    (('a option, 'b) t, 'b) Base.Result.t ->
    (('a, 'b) Base.Result.t -> 'c) ->
    ('c option, 'b) t
end

module type S = sig
  type 'a t

  include S2 with type ('a, 'b) t := 'a t
end

(* Deprecated *)

module Syntax2' (Monad : Base.Monad.S2) = struct
  let ( >>=: ) = Monad.( >>= )
  let ( >>|: ) = Monad.( >>| )
  let ( let*: ) = ( >>=: )
  let ( let+: ) = ( >>|: )
  let ( and*: ) = Monad.Let_syntax.Let_syntax.both
  let ( and+: ) = Monad.Let_syntax.Let_syntax.both

  let ( let*?: ) v f =
    match v with None -> f None | Some v -> v >>=: fun v -> f (Some v)

  let ( let+?: ) v f =
    match v with
    | None -> Monad.return @@ f None
    | Some v -> v >>|: fun v -> f (Some v)
end

module Syntax' (Monad : Base.Monad.S) = struct
  include Syntax2' (struct
    include Monad

    type nonrec ('a, 'b) t = 'a t
  end)
end
