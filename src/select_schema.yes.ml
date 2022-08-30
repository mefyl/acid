module Either = struct
  let schema = Schematic.Schemas.Either.schema
  let schema_versioned = Schematic.Schemas.Either.schema_versioned
end

module type MODE = sig
  type 'a t

  val schema_versioned :
    Schematic.Schema.version -> 'a Schematic.Schema.t -> 'a t Schematic.Schema.t
end

module type SWITCH = sig
  type ('r, 'w) t

  val schema_versioned :
    Schematic.Version.t option ->
    'r Schematic.Schema.t ->
    'w Schematic.Schema.t ->
    ('r, 'w) t Schematic.Schema.t

  val schema :
    'r Schematic.Schema.t ->
    'w Schematic.Schema.t ->
    ('r, 'w) t Schematic.Schema.t
end

module R = struct end

module W = struct
  let schema_versioned = Schematic.Schemas.option_schema_versioned
  let schema s = schema_versioned (fun _ -> None) s
end

module Switch_r = struct end
module Switch_w = struct end

module type SPLIT = sig
  type ('l, 'r) t

  val schema_versioned :
    Schematic.Version.t option ->
    'r Schematic.Schema.t ->
    'w Schematic.Schema.t ->
    ('r, 'w) t Schematic.Schema.t

  val schema :
    'r Schematic.Schema.t ->
    'w Schematic.Schema.t ->
    ('r, 'w) t Schematic.Schema.t
end

module Split = struct end

module Int = struct
  let schema_versioned _ = Schematic.Schemas.int_schema
end

module String = struct
  let schema_versioned _ = Schematic.Schemas.string_schema
end

module List_nonempty = struct
  type 'a t = ( :: ) : 'a * 'a list -> 'a t

  let schema_versioned _ parameter =
    let descriptor parameter =
      let decode = function
        | [] -> Result.fail "empty list"
        | hd :: tl -> Result.return (hd :: tl)
      and encode (hd :: tl) = List.cons hd tl in
      Schematic.Schema.Map { decode; encode; descriptor = List parameter }
    in
    Schematic.Schema.make
      ~id:(Schematic.Schema.name_combine parameter "list-nonempty")
      ~parametric:
        (Parametric
           {
             name = "a";
             parameter;
             next =
               (fun a ->
                 Plain { name = "list-nonempty"; descriptor = descriptor a });
           })
    @@ descriptor parameter

  let schema s = schema_versioned None s
end

module Map = struct
  module M (K : sig
    include Base.Comparator.S

    val schema_versioned : Schematic.Schema.version -> t Schematic.Schema.t
  end) =
  struct
    include Base.Map.M (K)

    let empty = Base.Map.empty (module K)

    let schema_versioned version =
      let key_schema = K.schema_versioned version in
      let pp_key = Schematic.Pp.of_schema key_schema in
      let res : 'data. 'data Schematic.Schema.t -> 'data t Schematic.Schema.t =
        match key_schema.descriptor with
        | String ->
          fun data_schema ->
            let open Schematic.Schema in
            let id =
              let open Fmt in
              str "%adictionary"
                (option (string ++ const char '-'))
                data_schema.id
            and descriptor =
              let descriptor = Mapping data_schema
              and decode l =
                match Base.Map.of_alist (module K) l with
                | `Duplicate_key k -> Result.failf "duplicate key: %a" pp_key k
                | `Ok map -> Result.return map
              and encode map = Base.Map.to_alist map in
              Map { descriptor; decode; encode }
            in
            make ~id descriptor
        | _ ->
          fun data_schema ->
            let open Schematic.Schema in
            let id =
              let open Fmt in
              str "%a%amap"
                (option (string ++ const char '-'))
                key_schema.id
                (option (string ++ const char '-'))
                data_schema.id
            and descriptor =
              let descriptor =
                List
                  (make
                  @@ Tuple
                       (Item
                          {
                            schema = key_schema;
                            rest = Item { schema = data_schema; rest = ItemEnd };
                          }))
              and decode l =
                let l = List.map l ~f:(fun (k, (d, ())) -> (k, d)) in
                match Base.Map.of_alist (module K) l with
                | `Duplicate_key k -> Result.failf "duplicate key: %a" pp_key k
                | `Ok map -> Result.return map
              and encode map =
                Base.Map.to_alist map
                |> List.map ~f:(fun (k, d) -> (k, (d, ())))
              in
              Map { descriptor; decode; encode }
            in
            make ~id descriptor
      in
      res

    let schema data_schema = schema_versioned (fun _ -> None) data_schema
  end
end
