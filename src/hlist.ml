type _ t =
  | ( :: ) : 'a * 'b t -> ('a -> 'b) t
  | [] : unit t

let length l =
  let rec loop : type l. int -> l t -> int =
   fun acc -> function
    | _ :: tl -> loop (acc + 1) tl
    | [] -> acc
  in
  loop 0 l
