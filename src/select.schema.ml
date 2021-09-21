module type S = sig
  type 'a t

  val schema : 'a Schematic.Schema.t -> 'a t Schematic.Schema.t
end

module type SWITCH = sig
  type ('r, 'w) t

  val schema :
    'r Schematic.Schema.t ->
    'w Schematic.Schema.t ->
    ('r, 'w) t Schematic.Schema.t
end

module R = struct
  let schema s = s
end

module W = struct
  let schema = Schematic.Schema.Schemas.option_schema
end

module Switch_r = struct
  let schema r _ = r
end

module Switch_w = struct
  let schema _ w = w
end

module type SPLIT = sig
  type ('l, 'r) t

  val schema :
    'r Schematic.Schema.t ->
    'w Schematic.Schema.t ->
    ('r, 'w) t Schematic.Schema.t
end

module Split = struct end
