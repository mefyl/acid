open Base

type 'a t = ( :: ) : 'a * 'a list -> 'a t

let map (hd :: tl) ~f = f hd :: List.map ~f tl

let hd = function
  | hd :: _ -> hd

let tl = function
  | _ :: tl -> tl

let to_list = function
  | hd :: tl -> List.cons hd tl

let equal f (l :: tl_l) (r :: tl_r) = f l r && List.equal f tl_l tl_r
