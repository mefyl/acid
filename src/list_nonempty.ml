open Base
include Select.List_nonempty

let append (lh :: lt) (rh :: rt) = lh :: (lt @ (rh :: rt))
let cons e (hd :: tl) = e :: hd :: tl
let filter (hd :: tl) ~f = List.filter (hd :: tl) ~f

let fold (hd :: tl) ~f =
  let rec loop acc = function [] -> acc | hd :: tl -> loop (f acc hd) tl in
  loop hd tl

let concat l = fold l ~f:append

let filter_map (hd :: tl) ~f =
  let tl = List.filter_map ~f tl in
  match f hd with None -> tl | Some hd -> hd :: tl

let map (hd :: tl) ~f = f hd :: List.map ~f tl

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

let mapi l ~f = rev (rev_mapi l ~f)
let hd = function hd :: _ -> hd
let tl = function _ :: tl -> tl
let to_list = function hd :: tl -> List.cons hd tl
let equal f (l :: tl_l) (r :: tl_r) = f l r && List.equal f tl_l tl_r
let pp ?sep p = Fmt.(using to_list @@ list ?sep p)
