include Hlist_intf

module Make2 (T : sig
  type ('a, 'b) t
end) : S2 with type ('t, 'tag) value = ('t, 'tag) T.t = struct
  type ('t, 'tag) value = ('t, 'tag) T.t

  type ('t, 'tag) t =
    | ( :: ) : ('hd, 'tag) value * ('tl, 'tag) t -> (('hd, 'tl) desc, 'tag) t
    | [] : (unit, 'tag) t

  let length l =
    let rec loop : type l. int -> (l, 'tag) t -> int =
     fun acc -> function
      | _ :: tl -> loop (acc + 1) tl
      | [] -> acc
    in
    loop 0 l

  type 'res imapper = { f : 't 'tag. int -> ('t, 'tag) value -> 'res }

  let filter_mapi l ~(f : 'res option imapper) =
    let rec map : type a. int -> (a, 'tag) t -> 'res list =
     fun i -> function
      | hd :: tl -> (
        match f.f i hd with
        | Some value -> List.cons value (map (i + 1) tl)
        | None -> map (i + 1) tl)
      | [] -> List.[]
    in
    map 0 l

  let mapi l ~f = filter_mapi ~f:{ f = (fun i x -> Some (f.f i x)) } l

  let iteri l ~f =
    let (_ : unit list) = mapi ~f l in
    ()

  type 'res mapper = { f : 't 'tag. ('t, 'tag) value -> 'res }

  let filter_map l ~(f : 'res option mapper) =
    filter_mapi l ~f:{ f = (fun _ v -> f.f v) }

  let map l ~f = filter_map ~f:{ f = (fun x -> Some (f.f x)) } l

  let iter l ~f = map ~f l |> ignore
end

module Transduce2 (From : S2) (To : S2) = struct
  type imapper = {
    f : 'a 'b 'c. int -> ('a, 'b) From.value -> ('a, 'c) To.value;
  }

  let mapi l ~f:{ f } =
    let rec map : type a b c. int -> (a, b) From.t -> (a, c) To.t =
     fun i -> function
      | hd :: tl -> f i hd :: map (i + 1) tl
      | [] -> []
    in
    map 0 l

  type mapper = { f : 'a 'b 'c. ('a, 'b) From.value -> ('a, 'c) To.value }

  let map l ~f:{ f } = mapi l ~f:{ f = (fun _ v -> f v) }
end

module Transduce_2 (From : S) (To : S2) = struct
  type imapper = { f : 'a 'b. int -> 'a From.value -> ('a, 'b) To.value }

  let mapi l ~f:{ f } =
    let rec map : type a b. int -> a From.t -> (a, b) To.t =
     fun i -> function
      | hd :: tl -> f i hd :: map (i + 1) tl
      | [] -> []
    in
    map 0 l

  type mapper = { f : 'a 'b. 'a From.value -> ('a, 'b) To.value }

  let map l ~f:{ f } = mapi l ~f:{ f = (fun _ v -> f v) }
end

module Make (T : sig
  type 'a t
end) : S with type 'a value = 'a T.t = struct
  type 't value = 't T.t

  type 't t =
    | ( :: ) : 'hd value * 'tl t -> ('hd, 'tl) desc t
    | [] : unit t

  let length l =
    let rec loop : type l. int -> l t -> int =
     fun acc -> function
      | _ :: tl -> loop (acc + 1) tl
      | [] -> acc
    in
    loop 0 l

  type 'res imapper = { f : 't. int -> 't value -> 'res }

  let filter_mapi l ~(f : 'res option imapper) =
    let rec map : type a. int -> a t -> 'res list =
     fun i -> function
      | hd :: tl -> (
        match f.f i hd with
        | Some value -> List.cons value (map (i + 1) tl)
        | None -> map (i + 1) tl)
      | [] -> List.[]
    in
    map 0 l

  let mapi l ~f = filter_mapi ~f:{ f = (fun i x -> Some (f.f i x)) } l

  let iteri l ~f =
    let (_ : unit list) = mapi ~f l in
    ()

  type 'res mapper = { f : 't. 't value -> 'res }

  let filter_map l ~(f : 'res option mapper) =
    filter_mapi l ~f:{ f = (fun _ v -> f.f v) }

  let map l ~f = filter_map ~f:{ f = (fun x -> Some (f.f x)) } l

  let iter l ~f = map ~f l |> ignore
end

module Transduce (From : S) (To : S) = struct
  type imapper = { f : 't. int -> 't From.value -> 't To.value }

  let mapi l ~f:{ f } =
    let rec map : type a. int -> a From.t -> a To.t =
     fun i -> function
      | hd :: tl -> f i hd :: map (i + 1) tl
      | [] -> []
    in
    map 0 l

  type mapper = { f : 't. 't From.value -> 't To.value }

  let map l ~f:{ f } = mapi l ~f:{ f = (fun _ v -> f v) }
end

include Make (struct
  type 'a t = 'a
end)

let rec to_pairs : type l. l t -> l = function
  | a :: b -> (a, to_pairs b)
  | [] -> ()
