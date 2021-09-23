include Hlist_intf

let length l =
  let rec loop : type l. int -> l t -> int =
   fun acc -> function
    | _ :: tl -> loop (acc + 1) tl
    | [] -> acc
  in
  loop 0 l

module Make2 (T : sig
  type ('a, 'b) t
end) : S2 with type ('t, 'tag) value = ('t, 'tag) T.t = struct
  type ('t, 'tag) value = ('t, 'tag) T.t

  type ('t, 'tag) t =
    | ( :: ) : ('hd, 'tag) value * ('tl, 'tag) t -> ('hd -> 'tl, 'tag) t
    | [] : (unit, 'tag) t

  let length l =
    let rec loop : type l tag. int -> (l, tag) t -> int =
     fun acc -> function
      | _ :: tl -> loop (acc + 1) tl
      | [] -> acc
    in
    loop 0 l

  type 'res mapper = { f : 't 'tag. ('t, 'tag) value -> 'res }

  let filter_map l ~(f : 'res option mapper) =
    let rec map : type a tag. (a, tag) t -> 'res list = function
      | hd :: tl -> (
        match f.f hd with
        | Some value -> List.cons value (map tl)
        | None -> map tl)
      | [] -> List.[]
    in
    map l

  let map l ~(f : 'res mapper) = filter_map ~f:{ f = (fun x -> Some (f.f x)) } l
end

module Make (T : sig
  type 'a t
end) : S with type 'a value = 'a T.t = struct
  type 't value = 't T.t

  type 't t =
    | ( :: ) : 'hd value * 'tl t -> ('hd -> 'tl) t
    | [] : unit t

  let length l =
    let rec loop : type l. int -> l t -> int =
     fun acc -> function
      | _ :: tl -> loop (acc + 1) tl
      | [] -> acc
    in
    loop 0 l

  type 'res mapper = { f : 't. 't value -> 'res }

  let filter_map l ~(f : 'res option mapper) =
    let rec map : type a. a t -> 'res list = function
      | hd :: tl -> (
        match f.f hd with
        | Some value -> List.cons value (map tl)
        | None -> map tl)
      | [] -> List.[]
    in
    map l

  let map l ~(f : 'res mapper) = filter_map ~f:{ f = (fun x -> Some (f.f x)) } l
end
