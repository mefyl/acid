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
          let descriptor =
            List
              (make
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
                   })
          and decode l =
            let l = List.map l ~f:(fun (k, (d, ())) -> (k, d)) in
            match Base.Map.of_alist (module K) l with
            | `Duplicate_key k -> Result.failf "duplicate key: %a" pp_key k
            | `Ok map -> Result.return map
          and encode map =
            Base.Map.to_alist map |> List.map ~f:(fun (k, d) -> (k, (d, ())))
          in
          Map { descriptor; decode; encode }
        in
        make ~id descriptor
      in
      res

    let schema_versioned version =
      let key_schema = K.schema_versioned version in
      let (Flatten { descriptor; decode; encode }) =
        Schematic.Schema.flatten key_schema.descriptor
      in
      let pp_key = Schematic.Pp.of_schema key_schema in
      let res : 'data. 'data Schematic.Schema.t -> 'data t Schematic.Schema.t =
        match descriptor with
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
                let open Let.Syntax2 (Result) in
                let* l =
                  List.map
                    ~f:(fun (key, data) ->
                      let+ key = decode key in
                      (key, data))
                    l
                  |> Result.all
                in
                match Base.Map.of_alist (module K) l with
                | `Duplicate_key k -> Result.failf "duplicate key: %a" pp_key k
                | `Ok map -> Result.return map
              and encode map =
                Base.Map.to_alist map
                |> List.map ~f:(fun (key, data) -> (encode key, data))
              in
              Map { descriptor; decode; encode }
            in
            make ~id descriptor
        | _ -> fun schema -> assoc_schema_versioned version schema
      in
      res

    let schema data_schema = schema_versioned (fun _ -> None) data_schema
  end
end
