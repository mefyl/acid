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
    Schematic.Schema.version ->
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
    Schematic.Schema.version ->
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
  include Select.List_nonempty

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
  module type KEY = sig
    include Base.Comparator.S

    val schema_versioned : Schematic.Schema.version -> t Schematic.Schema.t
  end

  module M (K : KEY) = struct
    include Base.Map
    include Base.Map.M (K)

    let assoc_schema_versioned version =
      let key_schema = K.schema_versioned version in
      let pp_key = Schematic.Pp.of_schema key_schema in
      let res : 'data. 'data Schematic.Schema.t -> 'data t Schematic.Schema.t =
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
          let item =
            Schematic.Schema.make
            @@ Tuple
                 {
                   decode = Base.Fn.id;
                   encode = Base.Fn.id;
                   items =
                     Item
                       {
                         schema = key_schema;
                         rest = Item { schema = data_schema; rest = ItemEnd };
                       };
                 }
          and construct items =
            items
            |> Base.Sequence.map ~f:(fun Hlist.[ name; value ] -> (name, value))
            |> Base.Map.of_sequence (module K)
            |> function
            | `Duplicate_key k -> Result.failf "duplicate key: %a" pp_key k
            | `Ok map -> Result.return map
          and deconstruct map =
            Base.Map.to_sequence map
            |> Base.Sequence.map ~f:(fun (k, d) -> Hlist.[ k; d ])
          in
          Sequence { item; construct; deconstruct; length = Base.Map.length }
        in
        make ~id descriptor
      in
      res

    let rec descriptor_is_string :
        type t. t Schematic.Schema.descriptor -> (t, string) Type.eq option =
      function
      | Fixpoint t -> descriptor_is_string (Lazy.force t)
      | String -> Some Equal
      | _ -> None

    let schema_versioned version =
      let key_schema = K.schema_versioned version in
      let res :
          'data Schematic.Schema.t ->
          (K.t, 'data, K.comparator_witness) Base.Map.t Schematic.Schema.t =
        match descriptor_is_string key_schema.descriptor with
        | Some Equal ->
          (* This special case is handled by the generic one with Flatten just
             after, but is added here to avoid mapping Fn.id over keys for
             performance reasons. *)
          fun data_schema ->
           let deconstruct map = map |> Base.Map.to_sequence
           and construct sequence =
             match Base.Map.of_sequence (module K) sequence with
             | `Ok map -> Result.Ok map
             | `Duplicate_key key -> Result.failf "duplicate key in map: %S" key
           and id =
             let open Fmt in
             str "%adictionary"
               (option (string ++ const char '-'))
               data_schema.Schematic.Schema.id
           in
           let open Schematic.Schema in
           make ~id
           @@ Mapping
                {
                  construct;
                  deconstruct;
                  item = data_schema;
                  length = Base.Map.length;
                }
        | None -> (
          let pp_key = Schematic.Pp.of_schema key_schema in
          let (Flatten { descriptor; decode; encode }) =
            Schematic.Schema.flatten key_schema.descriptor
          in
          match descriptor with
          | String ->
            fun data_schema ->
              let deconstruct map =
                map
                |> Base.Map.to_sequence
                |> Base.Sequence.map ~f:(fun (key, data) -> (encode key, data))
              and construct sequence =
                sequence
                |> Base.Sequence.fold_m
                     ~init:(Base.Map.empty (module K))
                     ~return:Result.return ~bind:Result.bind
                     ~f:(fun map (key, data) ->
                       let open Let.Syntax2 (Result) in
                       let* key = decode key in
                       try
                         Base.Map.update map key ~f:(function
                           | None -> data
                           | Some _ ->
                             Fmt.failwith "duplicate key in map: %a" pp_key key)
                         |> Result.return
                       with Failure reason -> Result.fail reason)
              and id =
                let open Fmt in
                str "%adictionary"
                  (option (string ++ const char '-'))
                  data_schema.Schematic.Schema.id
              in
              let open Schematic.Schema in
              make ~id
              @@ Mapping
                   {
                     construct;
                     deconstruct;
                     item = data_schema;
                     length = Base.Map.length;
                   }
          | _ -> fun schema -> assoc_schema_versioned version schema)
      in
      res

    let schema data_schema = schema_versioned (fun _ -> None) data_schema
  end
end

module Set = struct
  module type ELT = sig
    include Base.Comparator.S

    val schema_versioned : Schematic.Schema.version -> t Schematic.Schema.t
  end

  module M (E : ELT) = struct
    include Base.Set
    include Base.Set.M (E)

    let schema_versioned version =
      let elt_schema = E.schema_versioned version in
      let open Schematic.Schema in
      let id =
        let open Fmt in
        str "%aset" (option (string ++ const char '-')) elt_schema.id
      and descriptor =
        let descriptor = List elt_schema
        and decode l = Base.Set.of_list (module E) l |> Result.return
        and encode set = Base.Set.to_list set in
        Map { descriptor; decode; encode }
      in
      make ~id descriptor

    let schema = schema_versioned (fun _ -> None)
  end
end
