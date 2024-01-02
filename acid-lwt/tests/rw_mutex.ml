open Acid_lwt
open Let.Syntax (Lwt)

let read_then_write () =
  let mutex = Lwt.Rw_mutex.make () in
  let a, wake_a = Lwt.wait ()
  and b, wake_b = Lwt.wait ()
  and step = ref 0 in
  let check ~here name n = Alcotest.(check ~here int) name n !step in
  let _read_a =
    Lwt.Rw_mutex.read mutex (fun () ->
        let+ () = a in
        step := !step + 1)
  and _read_b =
    Lwt.Rw_mutex.read mutex (fun () ->
        let+ () = b in
        step := !step + 1)
  in
  let () = check ~here:[%here] "nothing was run yet" 0 in
  let () = Lwt.wakeup wake_a () in
  let () = check ~here:[%here] "one reader was run" 1 in
  let write =
    Lwt.Rw_mutex.write mutex (fun () ->
        check ~here:[%here] "both reads are over" 2 |> Lwt.return)
  in
  let () = Lwt.wakeup wake_b () in
  let () = check ~here:[%here] "both readers were run" 2 in
  write

let () =
  let open Alcotest_lwt in
  let test_case name f = test_case name `Quick (fun _ -> f) in
  Lwt_main.run
  @@ run "Rw_mutex" [ ("", [ test_case "read then write" read_then_write ]) ]
