type ('a, 'b) t = ('a, 'b) Acid.Js.Pair.t

val fst : ('a, 'b) t Js_of_ocaml.Js.t -> 'a
val snd : ('a, 'b) t Js_of_ocaml.Js.t -> 'b
val to_pair : ('a, 'b) t Js_of_ocaml.Js.t -> 'a * 'b
val of_pair : 'a * 'b -> ('a, 'b) t Js_of_ocaml.Js.t
