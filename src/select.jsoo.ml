module Either = struct
  let schema = Schematic.Schemas.Either.schema
  let schema_versioned = Schematic.Schemas.Either.schema_versioned

  type (_, _) js = Js_of_ocaml.Js.Unsafe.any
end

module type S = sig
  type 'a t
  type 'a js

  val schema_versioned :
    Schematic.Version.t option ->
    'a Schematic.Schema.t ->
    'a t Schematic.Schema.t

  val schema : 'a Schematic.Schema.t -> 'a t Schematic.Schema.t
end

module type SWITCH = sig
  type ('r, 'w) t
  type ('r, 'w) js

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

module R = struct
  type 'a js = 'a
end

module W = struct
  let schema_versioned = Schematic.Schemas.option_schema_versioned
  let schema s = schema_versioned None s

  type 'a js = 'a Js_of_ocaml.Js.Opt.t
end

module Switch_r = struct
  type ('r, _) js = 'r
end

module Switch_w = struct
  type (_, 'w) js = 'w
end

module type SPLIT = sig
  type ('l, 'r) t
  type ('l, 'r) js

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

module Split = struct
  type ('l, 'r) js = Js_of_ocaml.Js.Unsafe.any
end

module List_nonempty = struct
  (* FIXME: factor *)
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

  let schema parameter =
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
end
