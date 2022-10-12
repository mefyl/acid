module Js = Js_of_ocaml.Js
include Acid.Js.Map

let ctor () : ('k, 'v) t Js.t Js.constr = Js.Unsafe.pure_js_expr "Map"

let of_map key data map =
  let ctor = ctor () in
  let res = new%js ctor in
  let () =
    let f ~key:k ~data:d =
      let key = key k
      and data = data d in
      res##set key data
    in
    Base.Map.iteri map ~f
  in
  res

let to_sequence map =
  let f iterator =
    let next = iterator##next in
    if Js.to_bool next##.done_ then None
    else Some (Pair.to_pair next##.value, iterator)
  in
  Base.Sequence.unfold ~init:map##entries ~f

let keys (map : ('k, 'v) t Js.t) =
  let f (iterator : 'a Iterator.t Js.t) =
    let next = iterator##next in
    if Js.to_bool next##.done_ then None else Some (next##.value, iterator)
  in
  Base.Sequence.unfold ~init:map##keys ~f

let data (map : ('k, 'v) t Js.t) =
  let f (iterator : 'a Iterator.t Js.t) =
    let next = iterator##next in
    if Js.to_bool next##.done_ then None else Some (next##.value, iterator)
  in
  Base.Sequence.unfold ~init:map##values ~f
