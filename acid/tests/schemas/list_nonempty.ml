open Acid

module Schemas_library = struct
  type Schematic.Schema.library += V

  let v = V
end

let pp elt =
  Fmt.using List_nonempty.to_list
  @@ Fmt.(const char '[' ++ list ~sep:semi elt ++ const char ']')

let list_nonempty elt =
  Alcotest.testable
    (pp (Alcotest.pp elt))
    (List_nonempty.equal (Alcotest.equal elt))

let decoding_error =
  Alcotest.testable Schematic.Error.pp_decoding Schematic.Error.equal_decoding

let literal () =
  let l = List_nonempty.[ 0; 1 ] in
  Alcotest.(check int "head" 0 @@ List_nonempty.hd l);
  Alcotest.(check (list int) "tail" [ 1 ] @@ List_nonempty.tl l);
  Alcotest.(check (list int) "to_list" [ 0; 1 ] @@ List_nonempty.to_list l);
  Alcotest.(check int "head" 0 @@ List_nonempty.hd l);
  let () =
    let l = List_nonempty.map ~f:Int.pred l in
    Alcotest.(check (list_nonempty int) "map" List_nonempty.[ -1; 0 ] l)
  in
  let () =
    let l =
      List_nonempty.filter_map
        ~f:(fun x -> Option.some_if (x > 0) (Int.pred x))
        l
    in
    Alcotest.(check (list int) "filter_map" [ 0 ] l)
  in
  ()

type ints = int List_nonempty.t [@@deriving schema]

let schema () =
  let () =
    let l = List_nonempty.[ 0; 1; 2 ] in
    let decoded =
      Schematic.Json.encode ints_schema l |> Schematic.Json.decode ints_schema
    in
    Alcotest.(check (result (list_nonempty int) decoding_error))
      "roundtrip of [0; 1; 2]" decoded
      (Result.Ok [ 0; 1; 2 ])
  and () =
    let decoded = Schematic.Json.decode ints_schema (`A []) in
    Alcotest.(check (result (list_nonempty int) decoding_error))
      "invalid empty JSON array" decoded
      (Result.Error { path = []; reason = "empty list"; schema = Some "ints" })
  in
  ()

let () =
  let test_case name f = Alcotest.test_case name `Quick f in
  Alcotest.run "Acid.List_nonempty"
    [
      ( "schematic coding",
        [ test_case "literal" literal; test_case "schema" schema ] );
    ]
