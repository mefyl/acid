include module type of Acid.Js.Map

val of_map :
  ('key -> 'js_key) ->
  ('data -> 'js_data) ->
  ('key, 'data, 'comparator_witness) Base.Map.t ->
  ('js_key, 'js_data) t Js_of_ocaml.Js.t

val to_sequence :
  ('key, 'data) t Js_of_ocaml.Js.t -> ('key * 'data) Base.Sequence.t

val keys : ('key, 'data) t Js_of_ocaml.Js.t -> 'key Base.Sequence.t
val data : ('key, 'data) t Js_of_ocaml.Js.t -> 'data Base.Sequence.t
