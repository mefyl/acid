include Mode_intf

module R = struct
  type 'a t = 'a

  include Select.R

  let return v = v
  let map f = f
  let get v = Some v
  let default v = v
  let if_optional _ = None
  let pp pp = pp
  let equal equal = equal

  module Switch = struct
    type ('r, _) t = 'r

    include Select.Switch_r

    let switch r _ = r
    let map f _ r = f r
  end
end

module W = struct
  type 'a t = 'a option

  include Select.W

  let return v = Some v
  let map f = Option.map f
  let get v = v
  let default _ = None
  let if_optional v = Some v

  let pp pp =
    Fmt.(option ~none:(const string "None") (const string "Some " ++ pp))

  let equal equal = Option.equal equal

  module Switch = struct
    type (_, 'w) t = 'w

    include Select.Switch_w

    let switch _ w = w
    let map _ f w = f w
  end
end
