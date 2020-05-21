module Let2 (Monad : Base.Monad.S2) = struct
  let ( >>= ) = Monad.( >>= )

  let ( >>| ) = Monad.( >>| )

  let ( let* ) = ( >>= )

  let ( let+ ) = ( >>| )

  let ( and* ) = Monad.Let_syntax.Let_syntax.both

  let ( and+ ) = Monad.Let_syntax.Let_syntax.both
end
