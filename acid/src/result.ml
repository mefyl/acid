(** Result extension *)

include Base.Result

let failf format = Fmt.kstr fail format

let both l r =
  l >>= fun l ->
  r >>= fun r -> return (l, r)

let to_option = function Ok v -> Some v | Error _ -> None

module ResultNestable :
  Monad.BASIC_NESTABLE2 with type ('t, 'e) t = ('t, 'e) t = struct
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

include (
  Monad.MakeNestable2
    (ResultNestable) :
      Monad.NESTABLE2 with type ('a, 'b) t := ('a, 'b) Base.Result.t)

(** A Result.all that doesn't blow up the call stack. *)
let all l =
  Base.List.fold_until l ~finish:(map ~f:Base.List.rev) ~init:(Ok [])
    ~f:(fun acc -> function
    | Ok x -> Continue (Base.Result.map acc ~f:(fun l -> x :: l))
    | Error e -> Stop (Error e))
