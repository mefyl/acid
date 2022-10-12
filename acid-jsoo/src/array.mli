type 'a t = 'a Js_of_ocaml.Js.js_array

val to_sequence : 'a t Js_of_ocaml.Js.t -> 'a Base.Sequence.t
val to_sequence_rev : 'a t Js_of_ocaml.Js.t -> 'a Base.Sequence.t
