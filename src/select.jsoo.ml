module type S = sig
  type 'a t

  type 'a js

  val schema : 'a Schematic.Schema.t -> 'a t Schematic.Schema.t
end

module type SWITCH = sig
  type ('r, 'w) t

  type ('r, 'w) js

  val schema :
    'r Schematic.Schema.t ->
    'w Schematic.Schema.t ->
    ('r, 'w) t Schematic.Schema.t
end

module R = struct
  type 'a js = 'a

  let schema s = s
end

module W = struct
  type 'a js = 'a Js_of_ocaml.Js.Opt.t

  let schema = Schematic.Schema.Schemas.option_schema
end

module Switch_r = struct
  type ('r, _) js = 'r

  let schema r _ = r
end

module Switch_w = struct
  type (_, 'w) js = 'w

  let schema _ w = w
end
