include Base.List

module ListNestable : Monad.BasicNestable with type 't t = 't t = struct
  type nonrec 't t = 't t

  let bind = bind
  let return = return
  let map = `Define_using_bind

  module Nest2 (M : Monad.S2) = struct
    let bind v ~f =
      let open Let.Syntax2 (M) in
      let rec fold = function
        | [] -> M.return []
        | head :: tail ->
          let+ head = f head
          and+ tail = fold tail in
          head :: tail
      in
      M.bind v ~f:fold |> M.map ~f:Base.List.concat
  end
end

include Monad.MakeNestable (ListNestable)
