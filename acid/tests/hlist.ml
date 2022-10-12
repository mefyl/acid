open Acid

let deconstruct () =
  let l = Hlist.[ 0; "1"; Some "2"; Some 3; 4; 5; 6; 7 ] in
  let f Hlist.[ a; b; c; d; e; f; g; h ] =
    Fmt.(
      str "%i %s %a %a %i %i %i %i" a b (option string) c (option int) d e f g h)
  in
  Alcotest.(check int "length" 8 @@ Hlist.length l);
  Alcotest.(check string "deconstructed" "0 1 2 3 4 5 6 7" @@ f l)

type _ atom =
  | Int : int -> int atom
  | String : string -> string atom

module Atom_hlist = Hlist.Make (struct
  type 'a t = 'a atom
end)

let find_map () =
  let l =
    Atom_hlist.[ Int 0; String "nope"; String "1"; String "2"; Int 3; Int 4 ]
  in
  let f n =
    let f : type t. t atom -> int option = function
      | Int i -> Option.some_if (i = n) i
      | String s -> (
        try
          let i = Int.of_string s in
          Option.some_if (i = n) i
        with _ -> None)
    in
    ({ f } : int option Atom_hlist.mapper)
  in
  Alcotest.(
    check (option int) "found int" (Some 3) Atom_hlist.(find_map ~f:(f 3) l));
  Alcotest.(
    check (option int) "found string" (Some 2) Atom_hlist.(find_map ~f:(f 2) l));
  Alcotest.(
    check (option int) "not found" None Atom_hlist.(find_map ~f:(f 5) l))

let () =
  let open Alcotest in
  run "Hlist"
    [
      ( "Hlist",
        [
          test_case "deconstruct" `Quick deconstruct;
          test_case "find_map" `Quick find_map;
        ] );
    ]
