include Let_intf

module Syntax2_suffixes
    (M : Base.Monad.S2)
    (Option : Monad.NESTABLE)
    (Result : Monad.NESTABLE2) =
struct
  let ( >>= ) = M.( >>= )
  let ( >>| ) = M.( >>| )
  let ( let* ) = ( >>= )
  let ( let+ ) = ( >>| )
  let ( and* ) = M.Let_syntax.Let_syntax.both
  let ( and+ ) = M.Let_syntax.Let_syntax.both

  (* Nested option result operators *)

  module Option_result = Option.Nest2 (Result.Nest2 (M))

  let ( >>=!? ) = Option_result.( >>= )
  let ( let*!? ) = Option_result.( >>= )
  let ( and*!? ) = Option_result.Let_syntax.Let_syntax.both
  let ( >>|!? ) = Option_result.( >>| )
  let ( let+!? ) = Option_result.( >>| )
  let ( and+!? ) = Option_result.Let_syntax.Let_syntax.both

  (* Nested option operators *)

  module Option = Option.Nest2 (M)

  let ( >>=? ) = Option.( >>= )
  let ( let*? ) = Option.( >>= )
  let ( and*? ) = Option.Let_syntax.Let_syntax.both
  let ( >>|? ) = Option.( >>| )
  let ( let+? ) = Option.( >>| )
  let ( and+? ) = Option.Let_syntax.Let_syntax.both

  (* Nested result operators *)

  module Result = Result.Nest2 (M)

  let ( >>=! ) = Result.( >>= )
  let ( let*! ) = Result.( >>= )
  let ( and*! ) = Result.Let_syntax.Let_syntax.both
  let ( >>|! ) = Result.( >>| )
  let ( let+! ) = Result.( >>| )
  let ( and+! ) = Result.Let_syntax.Let_syntax.both

  (* Option operators *)

  let ( >>=?? ) v f =
    match v with None -> f None | Some v -> v >>= fun v -> f (Some v)

  let ( let*?? ) = ( >>=?? )

  let ( >>|?? ) v f =
    match v with
    | None -> M.return @@ f None
    | Some v -> v >>| fun v -> f (Some v)

  let ( let+?? ) = ( >>|?? )

  (* Result operators *)

  let ( >>=!! ) v f =
    match v with
    | Base.Result.Error _ as e -> f e
    | Ok v -> v >>= fun v -> f (Ok v)

  let ( let*!! ) = ( >>=!! )

  let ( >>|!! ) v f =
    match v with
    | Base.Result.Error _ as e -> M.return @@ f e
    | Ok v -> v >>| fun v -> f (Ok v)

  let ( let+!! ) = ( >>|!! )
end

module Syntax2 (M : Base.Monad.S2) = struct
  include Syntax2_suffixes (M) (Option) (Result)
end

module Syntax_suffixes
    (M : Base.Monad.S)
    (Option : Monad.NESTABLE)
    (Result : Monad.NESTABLE2) =
  Syntax2_suffixes
    (struct
      include M

      type nonrec ('a, 'b) t = 'a t
    end)
    (Option)
    (Result)

module Syntax (Monad : Base.Monad.S) = Syntax2 (struct
  include Monad

  type nonrec ('a, 'b) t = 'a t
end)
