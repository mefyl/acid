open Acid_lwt
open Let.Syntax (Lwt)
module Sequence = Acid.Sequence.Make (Lwt)

let squared_odds init =
  let f = function
    | x when x < 0 -> Lwt.return Sequence.Step.Done
    | x when x % 2 = 0 -> Lwt.return @@ Sequence.Step.Skip (x - 1)
    | x -> Lwt.return @@ Sequence.Step.Yield (x * x, x - 1)
  in
  Sequence.unfold ~init ~f

let unfold _ () =
  let* res = Sequence.to_list @@ squared_odds 8 in
  Alcotest.(
    check ~here:[%here] (list int) "unfold |> to_list" [ 49; 25; 9; 1 ] res)
  |> Lwt.return

module Make
    (Monad : Base.Monad.S)
    (Walk :
      Acid.Sequence.WALKERS
        with type 'a sequence := 'a Sequence.t
         and type 'a monad := 'a Lwt.t
         and type 'a walk := 'a Monad.t) =
struct
  let filter_map _ () =
    let f i =
      if i % 3 = 0 then Monad.return (Some (i * 10)) else Monad.return None
    in
    let* res = Walk.filter_map (squared_odds 10) ~f |> Sequence.to_list in
    Alcotest.(
      check ~here:[%here] (list int) "filter_map |> to_list" [ 810; 90 ] res)
    |> Lwt.return
end

let memoize _ () =
  let operations = ref 0 in
  let perform i =
    operations := !operations + 1;
    i * i
  in
  let seq =
    let f i =
      if i < 5 then Lwt.return (Some (perform i, i + 1)) else Lwt.return None
    in
    Sequence.unfold_step ~init:0 ~f |> Sequence.memoize
  in
  let () =
    Alcotest.(check ~here:[%here] int) "operations count" 0 !operations
  in
  let* squares = Sequence.to_list seq in
  let () =
    Alcotest.(check ~here:[%here] (list int))
      "squares" [ 0; 1; 4; 9; 16 ] squares
  and () =
    Alcotest.(check ~here:[%here] int) "operations count" 5 !operations
  in
  let+ _squares_again = Sequence.to_list seq in
  Alcotest.(check ~here:[%here] int) "operations count" 5 !operations

let memoize_error _ () =
  let module Sequence = Acid.Sequence.Make2 (Lwt_result) in
  let fail_once =
    let first_time = ref true in
    let f () =
      if !first_time then
        let open Let.Syntax (Lwt) in
        let () = first_time := false in
        Lwt_result.fail ()
      else Lwt_result.return None
    in
    Sequence.unfold_step ~init:() ~f
  in
  let s =
    let unless p =
      match Lwt.state p with Return (Result.Error _) -> true | _ -> false
    in
    Sequence.concat (Sequence.of_list [ fail_once; Sequence.of_list [] ])
    |> Sequence.memoize_unless ~f:{ f = unless }
  in
  let* first = Sequence.to_list s in
  let () =
    Alcotest.(check ~here:[%here] (result (list pass) unit))
      "first" (Result.Error ()) first
  in
  let+ second = Sequence.to_list s in
  Alcotest.(check ~here:[%here] (result (list pass) unit))
    "second" (Result.Ok []) second

include Make (Base.Monad.Ident) (Sequence)
module Seq = Make (Lwt) (Sequence.Seq)

module Par = struct
  let iter _ () =
    let sequence = Sequence.of_list [ 1; 2; 3 ]
    and beacon = ref 0 in
    Sequence.Par.iter sequence ~f:(fun i ->
        let () = beacon := !beacon + i in
        let+ () = Lwt.pause () in
        Alcotest.(check ~here:[%here] int "beacon" 6 !beacon))
end

let () =
  let open Alcotest_lwt in
  let test_case name f = test_case name `Quick f in
  Lwt_main.run
  @@ run "Acid.Sequence"
       [
         ( "Lwt",
           [
             test_case "unfold" unfold;
             test_case "filter_map" filter_map;
             test_case "memoize" memoize;
             test_case "memoize error" memoize_error;
             test_case "Seq.filter_map" Seq.filter_map;
             test_case "Par.iter" Par.iter;
           ] );
       ]
