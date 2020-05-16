(** Result extension *)

include Base.Result

let both l r =
  l >>= fun l ->
  r >>= fun r -> return (l, r)
