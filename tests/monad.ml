open Acid

module Nest = struct
  module ResultList = Result.Nest (List)

  let list () =
    let open Let.Syntax2 (ResultList) in
    let inc v =
      let+ v = v in
      v + 1
    in
    Alcotest.(check (list (result int string)) "[]" [] (inc []));
    Alcotest.(
      check
        (list (result int string))
        "[0; 1; 2]"
        [ Result.Ok 1; Result.Ok 2; Result.Ok 3 ]
        (inc [ Result.Ok 0; Result.Ok 1; Result.Ok 2 ]));
    Alcotest.(
      check
        (list (result int string))
        "[0; 1; 2]"
        [ Result.Ok 1; Result.Error "coin"; Result.Error "pan"; Result.Ok 4 ]
        (inc
           [ Result.Ok 0; Result.Error "coin"; Result.Error "pan"; Result.Ok 3 ]))
end

let () =
  let test_case name f = Alcotest.test_case name `Quick f in
  Alcotest.run "Acid.Result" [ ("nest", [ test_case "list" Nest.list ]) ]
