open Acid.Versions.V0_10_0

module String = struct
  include String

  let schema_versioned version =
    let schema = schema_versioned version in
    let descriptor =
      Schematic.Schema.Map
        {
          encode = Fn.id;
          decode = Result.return;
          descriptor = Fixpoint (lazy schema.descriptor);
        }
    in
    { schema with descriptor }
end

module IntMap = Map.M (Int)
module StringMap = Map.M (String)

let json = Alcotest.testable Schematic.Json.pp Schematic.Json.equal

let int () =
  let empty = IntMap.empty in
  let full =
    empty |> Map.set ~key:1 ~data:"one" |> Map.set ~key:2 ~data:"two"
    |> Map.set ~key:3 ~data:"three"
  in
  let check name map expected =
    let encoded =
      Schematic.Json.encode IntMap.(schema Schematic.Schemas.string_schema) map
    in
    Alcotest.check json name expected encoded
  in
  check "empty" empty [%ezjsonm []];
  check "full" full [%ezjsonm [ [ 1; "one" ]; [ 2; "two" ]; [ 3; "three" ] ]]

let string () =
  let empty = StringMap.empty in
  let full =
    empty |> Map.set ~key:"one" ~data:1 |> Map.set ~key:"two" ~data:2
    |> Map.set ~key:"three" ~data:3
  in
  let check name map expected =
    let encoded =
      Schematic.Json.encode StringMap.(schema Schematic.Schemas.int_schema) map
    in
    Alcotest.check json name expected encoded
  in
  check "empty" empty (`O []);
  check "full" full [%ezjsonm { one = 1; two = 2; three = 3 }]

let () =
  Alcotest.run "Acid.Map.schema"
    [
      ( "JSON coding",
        [
          Alcotest.test_case "int keys" `Quick int;
          Alcotest.test_case "string keys" `Quick string;
        ] );
    ]
