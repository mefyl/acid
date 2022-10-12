include Split_intf

module Left : S with type ('l, 'r) t = 'l = struct
  type ('l, 'r) t = 'l

  include Select_schema.Split
  include Select_jsoo.Split

  let[@warning "-32"] schema_versioned _ l _ = l
  let[@warning "-32"] schema l r = schema_versioned (fun _ -> None) l r
  let make l _ = l
  let left v = Some v
  let right _ = None
  let get f _ v = f v
  let pp = make
  let equal = make
  let compare = make
end

module Right : S with type ('l, 'r) t = 'r = struct
  type ('l, 'r) t = 'r

  include Select_schema.Split
  include Select_jsoo.Split

  let[@warning "-32"] schema_versioned _ _ r = r
  let[@warning "-32"] schema l r = schema_versioned (fun _ -> None) l r
  let make _ r = r
  let left _ = None
  let right v = Some v
  let get _ f v = f v
  let pp = make
  let equal = make
  let compare = make
end
