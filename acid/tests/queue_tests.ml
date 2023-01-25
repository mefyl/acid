open Acid

type 't operation =
  | Queue of 't
  | Dequeue
[@@deriving show]

type check = {
  f :
    'a.
    here:Lexing.position ->
    pp:'a Fmt.t ->
    cmp:('a -> 'a -> int) ->
    eq:('a -> 'a -> bool) ->
    string ->
    'a ->
    'a ->
    unit;
}

let apply_op { f = check } (l, q) op =
  let l, q =
    match op with
    | Queue v ->
      Fmt.epr "Queue %i@." v;
      let l = l @ [ v ]
      and q = Queue.enqueue v q in
      (l, q)
    | Dequeue ->
      let lv, l = match l with [] -> (None, []) | hd :: tl -> (Some hd, tl)
      and qv, q = Queue.dequeue q in
      Fmt.epr "Dequeue %a@." Fmt.(option ~none:(const string "-") int) qv;
      let () =
        check ~here:[%here]
          ~pp:Fmt.(option int)
          ~cmp:(Option.compare Int.compare)
          ~eq:(Option.equal Int.equal) "dequeued value" lv qv
      in
      (l, q)
  in
  let () =
    check ~here:[%here] ~pp:Fmt.int ~cmp:Int.compare ~eq:Int.equal
      "queue length" (List.length l) (Queue.length q)
  and () =
    check ~here:[%here]
      ~pp:Fmt.(list ~sep:semi int)
      ~cmp:(List.compare Int.compare) ~eq:(List.equal Int.equal) "queue content"
      l (Queue.to_list q)
  and () = Queue.invariant q in
  (l, q)
