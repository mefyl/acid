open Base

type 'a t = {
  capacity : int;
  mutable position : int;
  mutable size : int;
  values : 'a option Array.t;
}

let make capacity =
  { capacity; position = 0; size = 0; values = Array.create ~len:capacity None }

let push v t =
  t.values.(t.position) <- Some v;
  t.position <-
    (let next = t.position + 1 in
     if next < t.capacity then next else 0);
  if t.size < t.capacity then t.size <- t.size + 1

let to_list t =
  let rec get acc pos = function
    | 0 -> acc
    | size ->
      let pos = (pos - 1) % t.size in
      get (Option.value_exn t.values.(pos) :: acc) pos (size - 1)
  in
  get [] t.position t.size
