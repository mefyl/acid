module Syntax2 (Monad : Base.Monad.S2) = struct
  let ( >>= ) = Monad.( >>= )
  let ( >>| ) = Monad.( >>| )
  let ( let* ) = ( >>= )
  let ( let+ ) = ( >>| )
  let ( and* ) = Monad.Let_syntax.Let_syntax.both
  let ( and+ ) = Monad.Let_syntax.Let_syntax.both

  (* Nested option operators *)

  let ( let*? ) v f =
    v >>= function
    | None -> Monad.return @@ None
    | Some v -> f v >>| Option.some

  let ( let+? ) v f =
    v >>= function
    | None -> Monad.return @@ None
    | Some v -> Monad.return (Some (f v))

  let ( let*?? ) v f =
    match v with None -> f None | Some v -> v >>= fun v -> f (Some v)

  let ( let+?? ) v f =
    match v with
    | None -> Monad.return @@ f None
    | Some v -> v >>| fun v -> f (Some v)

  (* Nested result operators *)

  let ( let*! ) v f =
    v >>= function
    | Result.Error _ as e -> Monad.return e
    | Result.Ok v -> f v >>| Result.return

  let ( let+! ) v f =
    v >>| function
    | Result.Error _ as e -> e
    | Result.Ok v -> f v |> Result.return

  let ( let*!! ) v f =
    match v with
    | Result.Error _ as e -> f e
    | Result.Ok v -> v >>= fun v -> f (Result.Ok v)

  let ( let+!! ) v f =
    match v with
    | Result.Error _ as e -> Monad.return @@ f e
    | Result.Ok v -> v >>| fun v -> f (Result.Ok v)
end

module Syntax (Monad : Base.Monad.S) = struct
  include Syntax2 (struct
    include Monad

    type nonrec ('a, 'b) t = 'a t
  end)
end

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
