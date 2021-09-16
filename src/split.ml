include Split_intf

module Left : S with type ('l, 'r) t = 'l = struct
  type ('l, 'r) t = 'l

  type ('l, 'r) js = Js_of_ocaml.Js.Unsafe.any

  let case l _ = l

  let make l _ = l

  let left v = Some v

  let right _ = None

  let get f _ v = f v

  let schema l _ = l
end

module Right : S with type ('l, 'r) t = 'r = struct
  type ('l, 'r) t = 'r

  type ('l, 'r) js = Js_of_ocaml.Js.Unsafe.any

  let case _ r = r

  let make _ r = r

  let left _ = None

  let right v = Some v

  let get _ f v = f v

  let schema _ r = r
end
