module Js = Js_of_ocaml.Js

type 'a t = 'a Js.js_array

let to_sequence (array : _ t Js.t) =
  let length = array##.length in
  let f n =
    if n >= length then None
    else Some (Js.array_get array n |> Caml.Obj.magic, n + 1)
  in
  Base.Sequence.unfold ~init:0 ~f

let to_sequence_rev (array : _ Js.js_array Js.t) =
  let length = array##.length in
  let f n =
    if n < 0 then None else Some (Js.array_get array n |> Caml.Obj.magic, n - 1)
  in
  Base.Sequence.unfold ~init:(length - 1) ~f
