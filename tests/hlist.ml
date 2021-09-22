open Acid

let deconstruct () =
  let l = Hlist.[ 0; "1"; Some "2"; Some 3; 4; 5; 6; 7 ] in
  let f Hlist.[ a; b; c; d; e; f; g; h ] =
    Fmt.(
      str "%i %s %a %a %i %i %i %i" a b (option string) c (option int) d e f g h)
  in
  Alcotest.(check string "deconstructed" "0 1 2 3 4 5 6 7" @@ f l)

let () =
  let open Alcotest in
  run "Hlist" [ ("Hlist", [ test_case "deconstruct" `Quick deconstruct ]) ]
