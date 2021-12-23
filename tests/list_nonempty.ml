open Acid

let pp elt =
  Fmt.using List_nonempty.to_list
  @@ Fmt.(const char '[' ++ list ~sep:semi elt ++ const char ']')

let list_nonempty elt =
  Alcotest.testable
    (pp (Alcotest.pp elt))
    (List_nonempty.equal (Alcotest.equal elt))

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

let () =
  let test_case name f = Alcotest.test_case name `Quick f in
  Alcotest.run "Acid.List_nonempty"
    [ ("list API", [ test_case "list API" literal ]) ]
