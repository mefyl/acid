module type S = sig
  type 'a t

  val schema_versioned :
    Schematic.Version.t option ->
    'a Schematic.Schema.t ->
    'a t Schematic.Schema.t

  val schema : 'a Schematic.Schema.t -> 'a t Schematic.Schema.t
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
  let schema s = schema_versioned None s
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

module List_nonempty = struct
  type 'a t = ( :: ) : 'a * 'a list -> 'a t

  let schema_versioned _ parameter =
    let descriptor parameter =
      let decode = function
        | [] -> Result.fail "empty list"
        | hd :: tl -> Result.return (hd :: tl)
      and encode (hd :: tl) = List.cons hd tl in
      Schematic.Schema.Map (decode, encode, List parameter)
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
