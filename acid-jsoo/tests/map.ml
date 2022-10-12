open Acid
open Acid_jsoo

let roundtrip () =
  let map =
    Map.empty (module String)
    |> Map.set ~key:"one" ~data:1 |> Map.set ~key:"two" ~data:2
    |> Map.set ~key:"three" ~data:3
  in
  let js_map = Js.Map.of_map Js.string Fn.id map in
  let roundtrip =
    Js.Map.to_sequence js_map
    |> Base.Sequence.map ~f:(fun (key, data) -> (Js.to_string key, data))
    |> Base.Sequence.to_list
  in
  Alcotest.(check ~here:[%here] (list (pair string int)) "roundrip map content")
    [ ("one", 1); ("three", 3); ("two", 2) ]
    roundtrip

let () =
  let open Alcotest in
  run "Acid_jsoo.Map" [ ("Map", [ test_case "roundtrip" `Quick roundtrip ]) ]
