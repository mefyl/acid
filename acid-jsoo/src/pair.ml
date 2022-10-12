module Js = Js_of_ocaml.Js
include Acid.Js.Pair

let fst pair = Js.Unsafe.get pair 0
let snd pair = Js.Unsafe.get pair 1
let to_pair pair = (fst pair, snd pair)

let of_pair (fst, snd) =
  Js.array [| Js.Unsafe.inject fst; Js.Unsafe.inject snd |] |> Js.Unsafe.coerce
