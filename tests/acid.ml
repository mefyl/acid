let noop () = Alcotest.(check bool "noop" true true)

let () =
  let open Alcotest in
  let test_case name f = test_case name `Quick f in
  run "SQML" [ ("Noop", [ test_case "noop" noop ]) ]
