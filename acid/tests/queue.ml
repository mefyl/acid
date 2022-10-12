open Acid

let find_update () =
  let q = IQueue.of_list [ 0; 1; 2; 3; 2; 1; 0 ] in
  let () =
    let f _ = None in
    let q, res = IQueue.find_update ~f q in
    Alcotest.(
      check
        (pair (list int) (option int))
        "untouched"
        ([ 0; 1; 2; 3; 2; 1; 0 ], None)
        (IQueue.to_list q, res))
  in
  let () =
    let f = function 2 -> Some 3 | _ -> None in
    let q, res = IQueue.find_update ~f q in
    Alcotest.(
      check
        (pair (list int) (option int))
        "updated"
        ([ 0; 1; 3; 3; 2; 1; 0 ], Some 3)
        (IQueue.to_list q, res))
  in
  ()

let rfind_update () =
  let q = IQueue.of_list [ 0; 1; 2; 3; 2; 1; 0 ] in
  let () =
    let f _ = None in
    let q, res = IQueue.rfind_update ~f q in
    Alcotest.(
      check
        (pair (list int) (option int))
        "untouched"
        ([ 0; 1; 2; 3; 2; 1; 0 ], None)
        (IQueue.to_list q, res))
  in
  let () =
    let f = function 2 -> Some 3 | _ -> None in
    let q, res = IQueue.rfind_update ~f q in
    Alcotest.(
      check
        (pair (list int) (option int))
        "updated"
        ([ 0; 1; 2; 3; 3; 1; 0 ], Some 3)
        (IQueue.to_list q, res))
  in
  ()

let () =
  let test_case name f = Alcotest.test_case name `Quick f in
  Alcotest.run "Acid.Queue"
    [
      ( "find_update",
        [
          test_case "find_update" find_update;
          test_case "rfind_update" rfind_update;
        ] );
    ]
