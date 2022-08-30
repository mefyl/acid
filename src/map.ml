include Base.Map

let change_map map k ~f =
  let res = ref None in
  let f v =
    let r, v = f v in
    let () = res := Some r in
    v
  in
  let map = Base.Map.change map k ~f in
  (Option.value_exn ~here:[%here] !res, map)

let mem_update map k ~f = Base.Map.change map k ~f:(Option.map ~f)

include Select.Map
