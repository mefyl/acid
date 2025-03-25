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
     ++ cut
     ++ const string "}"

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

module type KEY = Select_schema.Map.KEY

module M (K : KEY) = struct
  include Select.Map.M (K)
  include Select_schema.Map.M (K)
  include Select_jsoo.Map.M (K)

  let empty = Base.Map.empty (module K)
  let singleton k v = Base.Map.singleton (module K) k v
  let of_alist l = Base.Map.of_alist (module K) l
  let of_alist_exn l = Base.Map.of_alist_exn (module K) l
  let of_alist_multi l = Base.Map.of_alist_multi (module K) l
  let of_alist_or_error l = Base.Map.of_alist_or_error (module K) l
  let of_alist_fold l ~init ~f = Base.Map.of_alist_fold (module K) l ~init ~f
  let of_alist_reduce l ~f = Base.Map.of_alist_reduce (module K) l ~f
  let of_iteri ~iteri = Base.Map.of_iteri (module K) ~iteri
  let of_sorted_array l = Base.Map.of_sorted_array (module K) l

  let of_sorted_array_unchecked l =
    Base.Map.of_sorted_array_unchecked (module K) l

  let of_increasing_iterator_unchecked ~len ~f =
    Base.Map.of_increasing_iterator_unchecked (module K) ~len ~f

  let of_sequence_or_error l = Base.Map.of_sequence_or_error (module K) l
  let of_sequence_exn l = Base.Map.of_sequence_exn (module K) l
  let of_sequence_multi l = Base.Map.of_sequence_multi (module K) l

  let of_sequence_fold l ~init ~f =
    Base.Map.of_sequence_fold (module K) l ~init ~f

  let of_sequence_reduce l ~f = Base.Map.of_sequence_reduce (module K) l ~f
end

module type KEY_PRINTABLE = sig
  type t [@@deriving show]

  include KEY with type t := t
end

module M_printable (K : KEY_PRINTABLE) = struct
  include M (K)

  let pp pp_data = pp K.pp pp_data
end
