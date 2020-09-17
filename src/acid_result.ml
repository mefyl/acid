(** Result extension *)

include Base.Result

let both l r =
  l >>= fun l ->
  r >>= fun r -> return (l, r)

let to_option = function
  | Ok v -> Some v
  | Error _ -> None
