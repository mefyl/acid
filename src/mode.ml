include Mode_intf

module R = struct
  type 'a t = 'a

  include Select_schema.R
  include Select_jsoo.R

  let schema_versioned _ s = s [@@ocaml.warning "-unused-value-declaration"]
  let return v = v
  let map f = f
  let get v = Some v
  let default v = v
  let if_optional _ = None
  let pp pp = pp
  let equal equal = equal
  let compare compare = compare

  module Switch = struct
    type ('r, _) t = 'r

    include Select_schema.Switch_r
    include Select_jsoo.Switch_r

    let schema_versioned _ r _ = r

    let schema r w = schema_versioned None r w
      [@@ocaml.warning "-unused-value-declaration"]

    let switch r _ = r
    let map f _ r = f r
  end
end

module W = struct
  type 'a t = 'a option

  include Select_schema.W
  include Select_jsoo.W

  let return v = Some v
  let map f = Option.map ~f
  let get v = v
  let default _ = None
  let if_optional v = Some v

  let pp pp =
    Fmt.(option ~none:(const string "None") (const string "Some " ++ pp))

  let equal equal = Option.equal equal
  let compare compare = Option.compare compare

  module Switch = struct
    type (_, 'w) t = 'w

    include Select_schema.Switch_w
    include Select_jsoo.Switch_w

    let schema_versioned _ _ w = w

    let schema r w = schema_versioned None r w
      [@@ocaml.warning "-unused-value-declaration"]

    let switch _ w = w
    let map _ f w = f w
  end
end
