open Acid

let check =
  {
    Queue_tests.f =
      (fun ~here ~pp ~cmp:_ ~eq name exp eff ->
        Alcotest.check ~here (Alcotest.testable pp eq) name exp eff);
  }

let queuing () =
  let check ops =
    List.fold ops ~init:([], Queue.empty) ~f:(Queue_tests.apply_op check)
    |> ignore
  in
  check [];
  check
    [ Queue 0; Queue 1; Queue 2; Queue 4; Dequeue; Dequeue; Dequeue; Dequeue ];
  check
    [
      Dequeue;
      Queue 1;
      Queue 2;
      Dequeue;
      Queue 3;
      Queue 4;
      Dequeue;
      Dequeue;
      Dequeue;
      Dequeue;
    ]

let () =
  let test_case name f = Alcotest.test_case name `Quick f in
  Alcotest.run "Acid.Queue" [ ("queuing", [ test_case "queuing" queuing ]) ]
