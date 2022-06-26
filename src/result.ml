(** Result extension *)

include Base.Result

let both l r =
  l >>= fun l ->
  r >>= fun r -> return (l, r)

let to_option = function Ok v -> Some v | Error _ -> None

module ResultNestable : Monad.BasicNestable2 with type ('t, 'e) t = ('t, 'e) t =
struct
  type nonrec ('t, 'e) t = ('t, 'e) t

  let bind = bind
  let return = return
  let map = `Define_using_bind

  module Nest2 (M : Monad.S2) = struct
    let bind v ~f =
      let f = function Error _ as e -> M.return e | Ok v -> f v in
      M.bind v ~f
  end
end

include Monad.MakeNestable2 (ResultNestable)
