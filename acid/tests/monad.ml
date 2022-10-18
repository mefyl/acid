open Acid

module Let = struct
  open Let.Syntax (List)

  let options () =
    let check ~here name eff exp =
      Alcotest.(check ~here (list @@ option int) name eff exp)
    in
    let () =
      let l =
        let l1 = [ Some 0; Some 1; Some 2 ]
        and l2 = [ Some 0; Some 1; Some 2 ] in
        let*? elt1 = l1
        and*? elt2 = l2 in
        if elt1 = elt2 then [ Some elt1 ] else [ None ]
      in
      check ~here:[%here] "let*?"
        [ Some 0; None; None; None; Some 1; None; None; None; Some 2 ]
        l
    and () =
      let l =
        let l1 = [ Some 0; Some 1; Some 2 ]
        and l2 = [ Some 0; Some 1; Some 2 ] in
        let+? elt1 = l1
        and+? elt2 = l2 in
        elt1 + elt2
      in
      check ~here:[%here] "let+?"
        [
          Some 0; Some 1; Some 2; Some 1; Some 2; Some 3; Some 2; Some 3; Some 4;
        ]
        l
    in
    ()
end

module Nest = struct
  module ResultList = Result.Nest (List)

  let list () =
    let open Acid.Let.Syntax2 (ResultList) in
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
  Alcotest.run "Acid.Result"
    [
      ("let", [ test_case "options operators" Let.options ]);
      ("nest", [ test_case "list" Nest.list ]);
    ]
