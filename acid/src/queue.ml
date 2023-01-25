(** Immutable queues *)

open Base

type 'a t = {
  tree : 'a tree option;
  size : int;
}

and 'a tree = {
  value : 'a;
  left : 'a tree option;
  right : 'a tree option;
}

let empty = { size = 0; tree = None }
let length { size; _ } = size

let enqueue value { size; tree } =
  let rec enqueue = function
    | 0, None -> { value; left = None; right = None }
    | 0, Some _ -> failwith "invariant error"
    | n, Some tree when n % 2 = 0 ->
      { tree with right = Some (enqueue ((n / 2) - 1, tree.right)) }
    | n, Some tree -> { tree with left = Some (enqueue (n / 2, tree.left)) }
    | _, None -> failwith "invariant error"
  in
  { size = size + 1; tree = Some (enqueue (size, tree)) }

let dequeue = function
  | { size = 0; _ } as queue -> (None, queue)
  | { tree = None; _ } -> failwith "invariant error"
  | { size; tree = Some { value; _ } as tree } ->
    let rec dequeue = function
      | Some { left = Some left; right; _ } ->
        Some { value = left.value; left = right; right = dequeue (Some left) }
      | _ -> None
    in
    (Some value, { size = size - 1; tree = dequeue tree })

let invariant { size; tree } =
  let rec invariant = function
    | None -> 0
    | Some { left; right; _ } ->
      let left = invariant left
      and right = invariant right in
      assert (left = right || left = right + 1);
      left + right + 1
  in
  assert (invariant tree = size)

let peek = function { tree = Some { value; _ }; _ } -> Some value | _ -> None

let map queue ~f =
  let rec map = function
    | None -> None
    | Some { value; left; right } ->
      Some { value = f value; left = map left; right = map right }
  in
  { queue with tree = map queue.tree }

let nth queue n =
  let rec nth = function
    | _, None -> None
    | 0, Some { value; _ } -> Some value
    | n, Some tree when n % 2 = 0 -> nth ((n / 2) - 1, tree.right)
    | n, Some tree -> nth (n / 2, tree.left)
  in
  nth (n, queue.tree)

let to_sequence queue =
  Base.Sequence.unfold ~init:(queue, 0) ~f:(fun (queue, n) ->
      match nth queue n with
      | Some value -> Some (value, (queue, n + 1))
      | None -> None)

let fold queue ~init ~f = to_sequence queue |> Base.Sequence.fold ~init ~f
let of_list l = List.fold l ~init:empty ~f:(fun queue v -> enqueue v queue)
let to_list queue = to_sequence queue |> Base.Sequence.to_list

let equal eq l r =
  let rec equal = function
    | Some l, Some r ->
      eq l.value r.value && equal (l.left, r.left) && equal (l.right, r.right)
    | None, None -> true
    | _ -> false
  in
  l.size = r.size && equal (l.tree, r.tree)
