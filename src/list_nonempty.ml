open Base

type 'a t = ( :: ) : 'a * 'a list -> 'a t

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

let hd = function
  | hd :: _ -> hd

let tl = function
  | _ :: tl -> tl

let to_list = function
  | hd :: tl -> List.cons hd tl

let equal f (l :: tl_l) (r :: tl_r) = f l r && List.equal f tl_l tl_r

let pp ?sep p = Fmt.(using to_list @@ list ?sep p)
