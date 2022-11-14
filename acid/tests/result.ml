open Acid

let all () =
  Alcotest.(check (result (list int) string))
    "all ok"
    (Result.Ok [ 0; 1; 2 ])
    (Result.all [ Result.Ok 0; Result.Ok 1; Result.Ok 2 ]);
  Alcotest.(check (result (list int) string))
    "all error" (Result.Error "1")
    (Result.all [ Result.Ok 0; Result.Error "1"; Result.Error "2" ])

let () =
  let test_case name f = Alcotest.test_case name `Quick f in
  Alcotest.run "Acid.Result" [ ("Acid.Result", [ test_case "all" all ]) ]
