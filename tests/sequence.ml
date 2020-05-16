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

let () =
  let open Alcotest_lwt in
  let test_case name f = test_case name `Quick f in
  Lwt_main.run
  @@ run "Acid.Sequence" [ ("Lwt", [ test_case "unfold" Lwt.unfold ]) ]
