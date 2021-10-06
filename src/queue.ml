(** Immutable queues *)

open Base

(* FIXME: implement with Braun trees *)
type 'a t = 'a list

let empty = []

let length = List.length

let enqueue q v = v :: q

let rec dequeue = function
  | [] -> (None, [])
  | [ v ] -> (Some v, [])
  | h :: t ->
    let res, t = dequeue t in
    (res, h :: t)

let rec peek = function
  | [] -> None
  | [ v ] -> Some v
  | _ :: t -> peek t

let map = List.map

let fold = List.fold

let _find_update rev q f =
  let rec loop acc = function
    | [] ->
      if rev then
        (acc, None)
      else
        (q, None)
    | h :: t -> (
      match f h with
      | None -> loop (h :: acc) t
      | Some v ->
        if rev then
          (List.rev_append t (v :: acc), Some v)
        else
          (List.rev_append (v :: acc) t, Some v))
  in
  loop [] q

let find_update q ~f = _find_update false q f

let rfind_update q ~f = _find_update true (List.rev q) f

let of_list = Fn.id

let to_list = Fn.id

let equal = List.equal
