open Acid
open Queue_tests

let queue v = Crowbar.map [ v ] @@ fun v -> Queue v
let dequeue () = Crowbar.const Dequeue

let operation printer v =
  Crowbar.(
    choose [ queue v; dequeue () ] |> with_printer (pp_operation printer))

let check =
  {
    Queue_tests.f =
      (fun ~here:_ ~pp ~cmp ~eq _name exp eff ->
        Crowbar.check_eq ~pp ~eq ~cmp eff exp);
  }

let () =
  Crowbar.(
    add_test ~name:"Queue operations"
      [
        list1 (operation Fmt.int int);
        list1 (operation Fmt.int int);
        list1 (operation Fmt.int int);
        list1 (operation Fmt.int int);
      ])
  @@ fun ops1 ops2 ops3 ops4 ->
  Fmt.epr "NEW TEST@.";
  ops1 @ ops2 @ ops3 @ ops4
  |> List.fold ~init:([], Queue.empty) ~f:(Queue_tests.apply_op check)
  |> ignore
