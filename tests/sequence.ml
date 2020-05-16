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

  let unfold () =
    let div init =
      let f = function
        | 0 :: _ -> Result.fail "dividing by zero"
        | x :: tl -> Result.return (Sequence.Step.Yield (60 / x, tl))
        | [] -> Result.return Sequence.Step.Done
      in
      Sequence.unfold ~init ~f
    in
    let res = Sequence.to_list @@ div [ 4; 3; 2 ] in
    Alcotest.(
      check
        (result (list int) string)
        "unfold |> to_list"
        (Result.Ok [ 15; 20; 30 ])
        res);
    let res = Sequence.to_list @@ div [ 4; 0; 2 ] in
    Alcotest.(
      check
        (result (list int) string)
        "unfold |> to_list" (Result.Error "dividing by zero") res)
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
         ("Result", [ test_case_res "unfold" Result.unfold ]);
       ]
