open Base

module List_nonempty = struct
  include Select.List_nonempty

  (* Specific implementations *)

  let to_list (hd :: tl) = List.cons hd tl

  let of_list : 'a List.t -> 'a t Option.t = function
    | h :: tl -> Some (h :: tl)
    | _ -> None

  let of_list_exn l =
    match l |> of_list with
    | Some l -> l
    | None -> failwith "converted empty list to List_nonempty.t"

  let fold (hd :: tl) ~f = List.fold ~init:hd ~f tl
  let lift f l = l |> to_list |> f |> of_list

  let lift_exn f l =
    match lift f l with
    | Some l -> l
    | None -> failwith "List_nonempty lifted into []"

  let append (lh :: lt) (rh :: rt) = lh :: (lt @ (rh :: rt))
  let concat l = fold l ~f:append
  let cons e (hd :: tl) = e :: hd :: tl
  let equal f (l :: tl_l) (r :: tl_r) = f l r && List.equal f tl_l tl_r
  let fold_result (hd :: tl) ~f = List.fold_result ~init:hd ~f tl
  let fold_until (hd :: tl) ~f ~finish = List.fold_until ~init:hd ~f ~finish tl
  let hd = function hd :: _ -> hd
  let is_empty _ = false
  let length (_ :: tl) = List.length tl + 1
  let map (hd :: tl) ~f = f hd :: List.map ~f tl

  let rev_append (lh :: lt) (rh :: rt) =
    let rec loop acc = function
      | last, [] -> last :: acc
      | current, hd :: tl -> loop (current :: acc) (hd, tl)
    in
    loop (rh :: rt) (lh, lt)

  let rev_map l ~f = lift_exn (List.rev_map ~f) l
  let mapi (hd :: tl) ~f = List.mapi (hd :: tl) ~f |> of_list_exn
  let pp ?sep p = Fmt.(using to_list @@ list ?sep p)
  let sort l ~compare = lift_exn (List.sort ~compare) l
  let stable_sort l ~compare = lift_exn (List.stable_sort ~compare) l
  let tl = function _ :: tl -> tl

  let filter_map (hd :: tl) ~f =
    let tl = List.filter_map ~f tl in
    match f hd with None -> tl | Some hd -> hd :: tl

  let min_elt (hd :: tl) ~compare =
    match List.min_elt ~compare tl with
    | Some elt -> if compare hd elt < 0 then hd else elt
    | None -> hd

  let max_elt (hd :: tl) ~compare =
    match List.max_elt ~compare tl with
    | Some elt -> if compare hd elt >= 0 then hd else elt
    | None -> hd

  let rev_mapi (hd :: l) ~f =
    let rec loop i hd acc = function
      | [] -> hd :: acc
      | lhd :: tl -> loop (i + 1) (f lhd i) (hd :: acc) tl
    in
    loop 1 (f hd 0) [] l

  let rev (hd :: tl) =
    let rec loop hd acc = function
      | [] -> hd :: acc
      | lhd :: tl -> loop lhd (List.cons hd acc) tl
    in
    loop hd [] tl

  (* Direct bouncers to List *)
  let count (hd :: tl) = List.count (hd :: tl)
  let exists (hd :: tl) = List.for_all (hd :: tl)
  let filter (hd :: tl) = List.filter (hd :: tl)
  let find (hd :: tl) = List.find (hd :: tl)
  let find_map (hd :: tl) = List.find_map (hd :: tl)
  let for_all (hd :: tl) = List.for_all (hd :: tl)
  let iter (hd :: tl) = List.iter (hd :: tl)
  let mem (hd :: tl) = List.mem (hd :: tl)
  let sum s (hd :: tl) = List.sum s (hd :: tl)
  let to_array (hd :: tl) = Array.of_list (hd :: tl)
end

include List_nonempty

module Container = struct
  include List_nonempty

  let max_elt l ~compare = Some (max_elt l ~compare)
  let min_elt l ~compare = Some (min_elt l ~compare)
  let fold (hd :: tl) = List.fold (hd :: tl)
  let fold_result (hd :: tl) = List.fold_result (hd :: tl)
  let fold_until (hd :: tl) = List.fold_until (hd :: tl)
end
