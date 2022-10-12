include Base.Map

let pp pp_key pp_data =
  let open Fmt in
  let indent = 2 in
  using (fun map -> to_sequence map |> Base.Sequence.to_seq)
  @@ box
  @@ const string "{"
     ++ (hvbox ~indent:(indent - 1)
        @@ cut
           ++ seq ~sep:comma
                (box ~indent
                @@ pair ~sep:(const string ":" ++ sp) pp_key pp_data))
     ++ cut ++ const string "}"

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

module M (K : Select_schema.Map.KEY) = struct
  include Select.Map.M (K)
  include Select_schema.Map.M (K)
  include Select_jsoo.Map.M (K)

  let pp = pp
  let empty = Base.Map.empty (module K)
  let singleton k v = Base.Map.singleton (module K) k v
end
