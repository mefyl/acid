open Acid

module Ordered_string_by_hash = Multi_index.Ordered_by_unique (struct
  type value = string

  let get v =
    (* Hoping this is unique enough for the purpose of this test suite *)
    Caml.Hashtbl.hash v

  include Int
end)

module Ordered_string = Multi_index.Ordered (String)

module Ordered_string_caseless =
  Multi_index.Ordered_by
    (struct
      type value = string

      let get = Fn.id

      include String.Caseless
    end)
    (Ordered_string)

module Ordered_string_by_length =
  Multi_index.Ordered_by
    (struct
      type value = string

      let get = String.length

      include Int
    end)
    (Ordered_string)

module Strings = struct
  module Index =
    Multi_index.Index.Three (Ordered_string_by_length) (Ordered_string_caseless)
      (Ordered_string_by_hash)

  include Index.Make (String)
  module By_length = Ordered_string_by_length.Bind (First)
  module Caseless = Ordered_string_caseless.Bind (Second)
  module By_hash = Ordered_string_by_hash.Bind (Third)
end

module String_set = Caml.Set.Make (String)

let set elt =
  let pp fmt set =
    Set.iter
      ~f:(fun e ->
        Alcotest.pp elt fmt e;
        Fmt.comma fmt ())
      set
  in
  Alcotest.testable pp Set.equal

module Ordered = struct
  let by_length () =
    let test =
      Strings.empty |> Strings.add "Foo" |> Strings.add "foo"
      |> Strings.add "FOO" |> Strings.add "bar" |> Strings.add ""
      |> Strings.add "multi_index"
    in
    let () =
      Alcotest.(check ~here:[%here] bool) "mem" true
      @@ Strings.By_length.mem 0 test
    and () =
      Alcotest.(check ~here:[%here] bool) "mem" false
      @@ Strings.By_length.mem 1 test
    and () =
      Alcotest.(check ~here:[%here] bool) "mem" true
      @@ Strings.By_length.mem 3 test
    and () =
      Alcotest.(check ~here:[%here] (option (set string)))
        "find"
        (Some (Set.singleton (module String) ""))
      @@ Strings.By_length.find 0 test
    and () =
      Alcotest.(check ~here:[%here] (option (set string))) "find" None
      @@ Strings.By_length.find 1 test
    and () =
      Alcotest.(check ~here:[%here] (option (set string)))
        "find"
        (Some (Set.of_list (module String) [ "foo"; "Foo"; "FOO"; "bar" ]))
      @@ Strings.By_length.find 3 test
    in
    let test =
      test |> Strings.remove "none" |> Strings.remove "FOO" |> Strings.remove ""
    in
    let () =
      Alcotest.(check ~here:[%here] bool) "mem" false
      @@ Strings.By_length.mem 0 test
    and () =
      Alcotest.(check ~here:[%here] bool) "mem" false
      @@ Strings.By_length.mem 1 test
    and () =
      Alcotest.(check ~here:[%here] bool) "mem" true
      @@ Strings.By_length.mem 3 test
    and () =
      Alcotest.(check ~here:[%here] (option (set string))) "find" None
      @@ Strings.By_length.find 0 test
    and () =
      Alcotest.(check ~here:[%here] (option (set string))) "find" None
      @@ Strings.By_length.find 1 test
    and () =
      Alcotest.(check ~here:[%here] (option (set string)))
        "find"
        (Some (Set.of_list (module String) [ "foo"; "Foo"; "bar" ]))
      @@ Strings.By_length.find 3 test
    in
    ()
end

module Ordered_unique = struct
  let by_hash () =
    let test =
      Strings.empty |> Strings.add "foo" |> Strings.add "bar"
      |> Strings.add "baz"
    in
    let check_has test ~here s =
      Alcotest.(check ~here bool) "mem" true
      @@ Strings.By_hash.mem (Hashtbl.hash s) test;
      Alcotest.(check ~here:[%here] (option string)) "find" (Some s)
      @@ Strings.By_hash.find (Hashtbl.hash s) test
    and check_hasn't test ~here s =
      Alcotest.(check ~here bool) "mem" false
      @@ Strings.By_hash.mem (Hashtbl.hash s) test;
      Alcotest.(check ~here:[%here] (option string)) "find" None
      @@ Strings.By_hash.find (Hashtbl.hash s) test
    in
    let () = check_has test ~here:[%here] "foo"
    and () = check_has test ~here:[%here] "bar"
    and () = check_has test ~here:[%here] "baz"
    and () = check_hasn't test ~here:[%here] "quux" in
    let test =
      test |> Strings.remove "bar" |> Strings.remove "FOO" |> Strings.remove ""
    in
    let () = check_has test ~here:[%here] "foo"
    and () = check_hasn't test ~here:[%here] "bar"
    and () = check_has test ~here:[%here] "baz"
    and () = check_hasn't test ~here:[%here] "quux" in
    ()
end

let () =
  let open Alcotest in
  run "Acid.Multi_index"
    [
      ("Ordered", [ test_case "by length" `Quick Ordered.by_length ]);
      ("Ordered_unique", [ test_case "by hash" `Quick Ordered_unique.by_hash ]);
    ]
