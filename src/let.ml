module Syntax2 (Monad : Base.Monad.S2) = struct
  let ( >>= ) = Monad.( >>= )
  let ( >>| ) = Monad.( >>| )
  let ( let* ) = ( >>= )
  let ( let+ ) = ( >>| )
  let ( and* ) = Monad.Let_syntax.Let_syntax.both
  let ( and+ ) = Monad.Let_syntax.Let_syntax.both

  let ( let*? ) v f =
    match v with None -> f None | Some v -> v >>= fun v -> f (Some v)

  let ( let+? ) v f =
    match v with
    | None -> Monad.return @@ f None
    | Some v -> v >>| fun v -> f (Some v)

  let ( let*?? ) v f =
    v >>= function
    | None -> Monad.return @@ None
    | Some v -> f v >>| Option.some

  let ( let+?? ) v f =
    v >>= function
    | None -> Monad.return @@ None
    | Some v -> Monad.return (Some (f v))
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
