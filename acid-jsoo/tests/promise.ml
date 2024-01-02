open Acid_lwt

module Of_lwt = struct
  open Let.Syntax (Lwt)

  let exn () =
    Acid_jsoo.Js.Promise.of_lwt (fun () ->
        let* () = Js_of_ocaml_lwt.Lwt_js.yield () in
        failwith "oups")
    |> Acid_jsoo.Js.Promise.map ~f:(fun () ->
           Alcotest.fail ~here:[%here] "promised was fulfilled")
    |> Acid_jsoo.Js.Promise.catch ~f:(fun _ -> ())
    |> ignore
end

let () =
  let open Alcotest in
  run ~and_exit:false "Acid_jsoo.Promise"
    [ ("of_lwt", [ test_case "exception" `Quick Of_lwt.exn ]) ]
