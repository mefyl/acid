module Syntax2 (Monad : Base.Monad.S2) = struct
  let ( >>= ) = Monad.( >>= )
  let ( >>| ) = Monad.( >>| )
  let ( let* ) = ( >>= )
  let ( let+ ) = ( >>| )
  let ( and* ) = Monad.Let_syntax.Let_syntax.both
  let ( and+ ) = Monad.Let_syntax.Let_syntax.both

  (* Nested option operators *)

  let ( >>=? ) v f =
    v >>= function None -> Monad.return @@ None | Some v -> f v

  let ( let*? ) = ( >>=? )

  let ( and*? ) l r =
    Monad.Let_syntax.Let_syntax.both l r >>| function
    | Some l, Some r -> Some (l, r)
    | _ -> None

  let ( >>|? ) v f =
    v >>= function
    | None -> Monad.return @@ None
    | Some v -> Monad.return (Some (f v))

  let ( let+? ) = ( >>|? )
  let ( and+? ) = ( and*? )

  let ( >>=?? ) v f =
    match v with None -> f None | Some v -> v >>= fun v -> f (Some v)

  let ( let*?? ) = ( >>=?? )

  let ( >>|?? ) v f =
    match v with
    | None -> Monad.return @@ f None
    | Some v -> v >>| fun v -> f (Some v)

  let ( let+?? ) = ( >>|?? )

  (* Nested result operators *)

  let ( >>=! ) v f =
    v >>= function Result.Error _ as e -> Monad.return e | Result.Ok v -> f v

  let ( let*! ) = ( >>=! )

  let ( and*! ) l r =
    Monad.Let_syntax.Let_syntax.both l r >>| function
    | Result.Ok l, Result.Ok r -> Result.Ok (l, r)
    | (Result.Error _ as l), _ -> l
    | _, (Result.Error _ as r) -> r

  let ( >>|! ) v f =
    v >>| function
    | Result.Error _ as e -> e
    | Result.Ok v -> f v |> Result.return

  let ( let+! ) = ( >>|! )
  let ( and+! ) = ( and*! )

  let ( >>=!! ) v f =
    match v with
    | Result.Error _ as e -> f e
    | Result.Ok v -> v >>= fun v -> f (Result.Ok v)

  let ( let*!! ) = ( >>=!! )

  let ( >>|!! ) v f =
    match v with
    | Result.Error _ as e -> Monad.return @@ f e
    | Result.Ok v -> v >>| fun v -> f (Result.Ok v)

  let ( let+!! ) = ( >>|!! )

  (* Nested option result operators *)

  let ( >>=!? ) v f =
    v >>= function
    | Result.Error _ as e -> Monad.return e
    | Result.Ok None as none -> Monad.return none
    | Result.Ok (Some v) -> f v

  let ( let*!? ) = ( >>=!? )

  let ( and*!? ) l r =
    Monad.Let_syntax.Let_syntax.both l r >>| function
    | Result.Ok (Some l), Result.Ok (Some r) -> Result.Ok (Some (l, r))
    | (Result.Error _ as l), _ -> l
    | _, (Result.Error _ as r) -> r
    | Result.Ok None, _ | _, Result.Ok None -> Result.Ok None

  let ( >>|!? ) v f =
    v >>| function
    | Result.Error _ as e -> e
    | Result.Ok None as none -> none
    | Result.Ok (Some v) -> f v |> Option.return |> Result.return

  let ( let+!? ) = ( >>|!? )
  let ( and+!? ) = ( and*!? )
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
