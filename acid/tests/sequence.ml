open Acid

module Result_tests = struct
  module Sequence = Acid.Sequence.Make2 (Acid.Result)

  let div init =
    let f = function
      | 0 :: _ -> Result.fail "dividing by zero"
      | x :: tl when x < 0 -> Result.return (Sequence.Step.Skip tl)
      | x :: tl -> Result.return (Sequence.Step.Yield (60 / x, tl))
      | [] -> Result.return Sequence.Step.Done
    in
    Sequence.unfold ~init ~f

  let unfold () =
    let res = Sequence.to_list @@ div [ 4; -1; -2; 3; 2 ] in
    Alcotest.(
      check ~here:[%here]
        (result (list int) string)
        "unfold |> to_list"
        (Result.Ok [ 15; 20; 30 ])
        res);
    let res = Sequence.to_list @@ div [ -1; 4; 0; -3; 2 ] in
    Alcotest.(
      check ~here:[%here]
        (result (list int) string)
        "unfold |> to_list" (Result.Error "dividing by zero") res)

  let fold () =
    let seq = Sequence.of_list [ 1; 2; 3; 4; 5 ]
    and f a b =
      let res = a + b in
      if res < 100 then Result.Ok res else Result.Error "too big"
    in
    Alcotest.(
      check ~here:[%here] (result int string) "sum" (Result.Ok 15)
        (Sequence.Seq.fold ~init:0 ~f seq));
    Alcotest.(
      check ~here:[%here] (result int string) "too big a sum"
        (Result.Error "too big")
        (Sequence.Seq.fold ~init:90 ~f seq))

  let length () =
    let seq = Sequence.of_list [ 1; 2; 3; 4; 5 ] in
    Alcotest.(
      check ~here:[%here] (result int string) "length" (Result.Ok 5)
        (Sequence.length seq))

  let take () =
    let lst = List.init 10 ~f:(Fn.const 1) in
    (* Infinite sequence, but we'll only take a subset of it *)
    let seq = Sequence.unfold_step ~init:() ~f:(fun () -> Ok (Some (1, ()))) in
    Alcotest.(
      check ~here:[%here]
        (result (list int) string)
        "take" (Ok lst)
        (Sequence.to_list @@ Sequence.take seq 10))

  let group_fold () =
    let seq = Sequence.of_lists [ [ 1; 2 ]; [ 4; 6 ]; [ 3; 5; 8; 7; 9 ] ] in
    let init n = List_nonempty.[ n ]
    and f List_nonempty.(head :: tail) n =
      Option.some_if (n >= head) List_nonempty.(n :: head :: tail)
    in
    Alcotest.(
      check ~here:[%here]
        (result (list (list int)) string)
        "group_fold"
        (Result.Ok [ [ 1; 2; 4; 6 ]; [ 3; 5; 8 ]; [ 7; 9 ] ])
        Sequence.(
          group_fold seq ~init ~f |> to_list
          |> Result.map
               ~f:(List.map ~f:(Fn.compose List.rev List_nonempty.to_list))))
end

let () =
  let open Alcotest in
  let test_case name f = test_case name `Quick f in
  run "Acid.Sequence"
    [
      ( "Result",
        Result_tests.
          [
            test_case "unfold" unfold;
            test_case "fold" fold;
            test_case "length" length;
            test_case "take" take;
            test_case "group_fold" group_fold;
          ] );
    ]
