include Split_intf

module Left : S with type ('l, 'r) t = 'l = struct
  type ('l, 'r) t = 'l

  include Select.Split

  let[@warning "-32"] schema l _ = l

  let case l _ = l

  let make l _ = l

  let left v = Some v

  let right _ = None

  let get f _ v = f v

  let pp = make

  let equal = make
end

module Right : S with type ('l, 'r) t = 'r = struct
  type ('l, 'r) t = 'r

  include Select.Split

  let[@warning "-32"] schema _ r = r

  let case _ r = r

  let make _ r = r

  let left _ = None

  let right v = Some v

  let get _ f v = f v

  let pp = make

  let equal = make
end
