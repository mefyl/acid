open Acid

let empty () =
  let buffer = Circular.make 10 in
  Alcotest.(check ~here:[%here] (list int))
    "empty buffer" [] (Circular.to_list buffer)

let looped () =
  let buffer = Circular.make 4 in
  List.range 0 10
  |> List.iter ~f:(fun i ->
      let () = Circular.push i buffer in
      Alcotest.(check ~here:[%here] (list int))
        "buffer"
        (List.range (max 0 (i - 3)) (i + 1))
        (Circular.to_list buffer))

let () =
  let test_case name f = Alcotest.test_case name `Quick f in
  Alcotest.run "Acid.Circular"
    [
      ( "Circular buffers",
        [ test_case "empty" empty; test_case "looped" looped ] );
    ]
