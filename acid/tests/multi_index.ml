open Acid
module Ordered_string = Multi_index.Ordered (String)

module Ordered_string_by_hash = Multi_index.Ordered_by_unique (struct
  type value = string

  let get v =
    (* Hoping this is unique enough for the purpose of this test suite *)
    Stdlib.Hashtbl.hash v

  include Int
end)

module Multi_ordered_string_by_characters =
  Multi_index.Multi_ordered_by
    (struct
      type value = string

      let get = String.fold ~init:(Set.empty (module Char)) ~f:Set.add

      include Char
    end)
    (Ordered_string)

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

(* module Strings = struct
 *   module Index =
 *     Multi_index.Index.Three (Ordered_string_by_length) (Ordered_string_caseless)
 *       (Ordered_string_by_hash)
 *
 *   include Index.Make (String)
 *   module By_length = Ordered_string_by_length.Bind (First)
 *   module Caseless = Ordered_string_caseless.Bind (Second)
 *   module By_hash = Ordered_string_by_hash.Bind (Third)
 * end *)

module Strings = struct
  module Index_by_hash =
    Multi_index.Index.Two
      (Ordered_string_by_hash)
      (Multi_ordered_string_by_characters)

  module Index_caseless =
    Multi_index.Index.Add (Ordered_string_caseless) (Index_by_hash)

  module Index_by_length =
    Multi_index.Index.Add (Ordered_string_by_length) (Index_caseless)

  include Index_by_length.Make (String)
  module By_length = Ordered_string_by_length.Bind (Index_by_length.Head (Bind))

  module Caseless =
    Ordered_string_caseless.Bind
      (Index_caseless.Head (Index_by_length.Tail (Bind)))

  module By_hash =
    Ordered_string_by_hash.Bind
      (Index_by_hash.First (Index_caseless.Tail (Index_by_length.Tail (Bind))))

  module By_characters =
    Multi_ordered_string_by_characters.Bind
      (Index_by_hash.Second (Index_caseless.Tail (Index_by_length.Tail (Bind))))
end

module String_set = Stdlib.Set.Make (String)

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
      Strings.empty
      |> Strings.add "Foo"
      |> Strings.add "foo"
      |> Strings.add "FOO"
      |> Strings.add "bar"
      |> Strings.add ""
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

  let caseless () =
    let test =
      Strings.empty
      |> Strings.add "Foo"
      |> Strings.add "foo"
      |> Strings.add "FOO"
      |> Strings.add "bar"
      |> Strings.add "BAR"
      |> Strings.add "baz"
    in
    let check ~here test expected s =
      Alcotest.(check ~here bool) "mem" (Option.is_some expected)
      @@ Strings.Caseless.mem s test;
      Alcotest.(check ~here (option (set string))) "find" expected
      @@ Strings.Caseless.find s test
    in
    let () =
      check ~here:[%here] test
        (Some (Set.of_list (module String) [ "foo"; "Foo"; "FOO" ]))
        "foo"
    and () =
      check ~here:[%here] test
        (Some (Set.of_list (module String) [ "foo"; "Foo"; "FOO" ]))
        "fOo"
    and () =
      check ~here:[%here] test
        (Some (Set.of_list (module String) [ "bar"; "BAR" ]))
        "BAR"
    and () = check ~here:[%here] test None "quux" in
    let test = Strings.Caseless.remove "FoO" test in
    let () = check ~here:[%here] test None "foo"
    and () = check ~here:[%here] test None "fOo"
    and () =
      check ~here:[%here] test
        (Some (Set.of_list (module String) [ "bar"; "BAR" ]))
        "BAR"
    and () = check ~here:[%here] test None "quux" in
    ()

  let by_length_order () =
    let binding = Alcotest.(pair int (set string)) in
    let check ~here test expected =
      Alcotest.(check ~here (option binding)) "min" (List.hd expected)
      @@ Strings.By_length.min test;
      Alcotest.(check ~here (option binding)) "max" (List.last expected)
      @@ Strings.By_length.max test;
      Alcotest.(check ~here (list binding)) "to_sequence" expected
      @@ Base.Sequence.to_list (Strings.By_length.to_sequence test);
      Alcotest.(check ~here (list binding)) "to_sequence decreasing"
        (List.rev expected)
      @@ Base.Sequence.to_list
           (Strings.By_length.to_sequence ~order:`Decreasing test)
    in
    let () = check ~here:[%here] Strings.empty [] in
    let test =
      Strings.empty
      |> Strings.add "foo"
      |> Strings.add "multi_index"
      |> Strings.add ""
      |> Strings.add "bar"
    in
    let () =
      check ~here:[%here] test
        [
          (0, Set.singleton (module String) "");
          (3, Set.of_list (module String) [ "foo"; "bar" ]);
          (11, Set.singleton (module String) "multi_index");
        ]
    in
    let test = test |> Strings.remove "" |> Strings.remove "multi_index" in
    let () =
      check ~here:[%here] test
        [ (3, Set.of_list (module String) [ "foo"; "bar" ]) ]
    in
    ()
end

module Ordered_unique = struct
  let by_hash () =
    let test =
      Strings.empty
      |> Strings.add "foo"
      |> Strings.add "bar"
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

  let by_hash_order () =
    let check ~here test values =
      let expected =
        List.sort values ~compare:(Comparable.lift Int.compare ~f:Hashtbl.hash)
      in
      Alcotest.(check ~here (option string)) "min" (List.hd expected)
      @@ Strings.By_hash.min test;
      Alcotest.(check ~here (option string)) "max" (List.last expected)
      @@ Strings.By_hash.max test;
      Alcotest.(check ~here (list string)) "to_sequence" expected
      @@ Base.Sequence.to_list (Strings.By_hash.to_sequence test);
      Alcotest.(check ~here (list string)) "to_sequence decreasing"
        (List.rev expected)
      @@ Base.Sequence.to_list (Strings.By_hash.to_sequence ~order:`Decreasing test)
    in
    let () = check ~here:[%here] Strings.empty [] in
    let test =
      Strings.empty
      |> Strings.add "foo"
      |> Strings.add "bar"
      |> Strings.add "baz"
    in
    let () = check ~here:[%here] test [ "foo"; "bar"; "baz" ] in
    let test = Strings.remove "bar" test in
    let () = check ~here:[%here] test [ "foo"; "baz" ] in
    ()
end

module Multi_ordered = struct
  let by_characters () =
    let test =
      Strings.empty
      |> Strings.add "Foo"
      |> Strings.add "foo"
      |> Strings.add "FOO"
      |> Strings.add "bar"
      |> Strings.add "BAR"
      |> Strings.add "baz"
    in
    let check ~here test expected c =
      Alcotest.(check ~here bool) "mem" (Option.is_some expected)
      @@ Strings.By_characters.mem c test;
      Alcotest.(check ~here (option (set string))) "find" expected
      @@ Strings.By_characters.find c test
    in
    let () =
      check ~here:[%here] test
        (Some (Set.of_list (module String) [ "foo"; "Foo" ]))
        'o'
    and () =
      check ~here:[%here] test
        (Some (Set.of_list (module String) [ "bar"; "baz" ]))
        'a'
    and () =
      check ~here:[%here] test
        (Some (Set.of_list (module String) [ "baz" ]))
        'z'
    and () = check ~here:[%here] test None 'x' in
    ()

  let by_characters_order () =
    let binding = Alcotest.(pair char (set string)) in
    let check ~here test expected =
      Alcotest.(check ~here (option binding)) "min" (List.hd expected)
      @@ Strings.By_characters.min test;
      Alcotest.(check ~here (option binding)) "max" (List.last expected)
      @@ Strings.By_characters.max test;
      Alcotest.(check ~here (list binding)) "to_sequence" expected
      @@ Base.Sequence.to_list (Strings.By_characters.to_sequence test);
      Alcotest.(check ~here (list binding)) "to_sequence decreasing"
        (List.rev expected)
      @@ Base.Sequence.to_list
           (Strings.By_characters.to_sequence ~order:`Decreasing test)
    in
    let () = check ~here:[%here] Strings.empty [] in
    let test =
      Strings.empty
      |> Strings.add "foo"
      |> Strings.add "bar"
      |> Strings.add "baz"
    in
    let () =
      check ~here:[%here] test
        [
          ('a', Set.of_list (module String) [ "bar"; "baz" ]);
          ('b', Set.of_list (module String) [ "bar"; "baz" ]);
          ('f', Set.singleton (module String) "foo");
          ('o', Set.singleton (module String) "foo");
          ('r', Set.singleton (module String) "bar");
          ('z', Set.singleton (module String) "baz");
        ]
    in
    let test = Strings.remove "baz" test in
    let () =
      check ~here:[%here] test
        [
          ('a', Set.singleton (module String) "bar");
          ('b', Set.singleton (module String) "bar");
          ('f', Set.singleton (module String) "foo");
          ('o', Set.singleton (module String) "foo");
          ('r', Set.singleton (module String) "bar");
        ]
    in
    ()
end

let () =
  let open Alcotest in
  run "Acid.Multi_index"
    [
      ( "Ordered",
        [
          test_case "by length" `Quick Ordered.by_length;
          test_case "caseless" `Quick Ordered.caseless;
          test_case "by length order" `Quick Ordered.by_length_order;
        ] );
      ( "Ordered_unique",
        [
          test_case "by hash" `Quick Ordered_unique.by_hash;
          test_case "by hash order" `Quick Ordered_unique.by_hash_order;
        ] );
      ( "Multi_ordered",
        [
          test_case "by characters" `Quick Multi_ordered.by_characters;
          test_case "by characters order" `Quick
            Multi_ordered.by_characters_order;
        ] );
    ]
