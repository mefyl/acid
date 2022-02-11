open Acid

module Lwt = struct
  module Sequence = Acid.Sequence.Make (Lwt)

  let unfold _ () =
    let ( let* ) = Lwt.( >>= ) in
    let squared_odds init =
      let f = function
        | x when x < 0 -> Lwt.return Sequence.Step.Done
        | x when x % 2 = 0 -> Lwt.return @@ Sequence.Step.Skip (x - 1)
        | x -> Lwt.return @@ Sequence.Step.Yield (x * x, x - 1)
      in
      Sequence.unfold ~init ~f
    in
    let* res = Sequence.to_list @@ squared_odds 8 in
    Alcotest.(check (list int) "unfold |> to_list" [ 49; 25; 9; 1 ] res)
    |> Lwt.return
end

module Result = struct
  module Sequence = Acid.Sequence.Make2 (Result)

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
      check
        (result (list int) string)
        "unfold |> to_list"
        (Result.Ok [ 15; 20; 30 ])
        res);
    let res = Sequence.to_list @@ div [ -1; 4; 0; -3; 2 ] in
    Alcotest.(
      check
        (result (list int) string)
        "unfold |> to_list" (Result.Error "dividing by zero") res)

  let step () =
    let () =
      let res =
        let open Let.Syntax2 (Result) in
        let s = div [ 4; -1; 2 ] in
        let* head, s = Sequence.step s in
        let () = Alcotest.(check (option int) "head" (Some 15) head) in
        let* head, s = Sequence.step s in
        let () = Alcotest.(check (option int) "head" (Some 30) head) in
        let* head, s = Sequence.step s in
        let () = Alcotest.(check (option int) "head" None head) in
        let+ head, _ = Sequence.step s in
        Alcotest.(check (option int) "head" None head)
      in
      Alcotest.(check (result unit string) "res" (Result.Ok ()) res)
    and () =
      let res =
        let open Let.Syntax2 (Result) in
        let s = div [ 4; -1; 0; 2 ] in
        let+ head, s = Sequence.step s in
        let () = Alcotest.(check (option int) "head" (Some 15) head) in
        let res = Sequence.step s |> Result.map ~f:fst in
        let () =
          Alcotest.(
            check
              (result (option int) string)
              "head" (Result.Error "dividing by zero") res)
        in
        let res = Sequence.step s |> Result.map ~f:fst in
        Alcotest.(
          check
            (result (option int) string)
            "head" (Result.Error "dividing by zero") res)
      in
      Alcotest.(check (result unit string) "res" (Result.Ok ()) res)
    in
    ()

  let fold () =
    let seq = Sequence.of_list [ 1; 2; 3; 4; 5 ]
    and f a b =
      let res = a + b in
      if res < 100 then Result.Ok res else Result.Error "too big"
    in
    Alcotest.(
      check (result int string) "sum" (Result.Ok 15)
        (Sequence.fold ~init:0 ~f seq));
    Alcotest.(
      check (result int string) "too big a sum" (Result.Error "too big")
        (Sequence.fold ~init:90 ~f seq))

  let length () =
    let seq = Sequence.of_list [ 1; 2; 3; 4; 5 ] in
    Alcotest.(
      check (result int string) "length" (Result.Ok 5) (Sequence.length seq))
end

let () =
  let open Alcotest_lwt in
  let test_case name f = test_case name `Quick f
  and test_case_res name f =
    test_case name `Quick (fun _ () -> Acid.Lwt.return (f ()))
  in
  Lwt_main.run
  @@ run "Acid.Sequence"
       [
         ("Lwt", [ test_case "unfold" Lwt.unfold ]);
         ( "Result",
           [
             test_case_res "unfold" Result.unfold;
             test_case_res "step" Result.step;
             test_case_res "fold" Result.fold;
             test_case_res "length" Result.length;
           ] );
       ]
