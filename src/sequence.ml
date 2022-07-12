open Base
include Sequence_intf

module Step = struct
  include Step

  let of_base = function
    | Base.Sequence.Step.Done -> Done
    | Skip state -> Skip state
    | Yield (v, state) -> Yield (v, state)
end

module Make2 (Monad : Base.Monad.S2) = struct
  open Monad
  module Step = Step

  type ('a, 'b) t =
    | Sequence : {
        state : 's;
        f : 's -> (('a, 's) Step.t, 'b) Monad.t;
      }
        -> ('a, 'b) t

  let empty = Sequence { state = (); f = (fun () -> Monad.return Step.Done) }
  let unfold ~init ~f = Sequence { state = init; f }

  let unfold_step ~init ~f =
    let f s =
      f s >>| function
      | Some (s, state) -> Step.Yield (s, state)
      | None -> Step.Done
    in
    Sequence { state = init; f }

  let of_base init =
    let f s =
      Base.Sequence.Expert.next_step s |> Step.of_base |> Monad.return
    in
    unfold ~init ~f

  let of_list init =
    let f = function
      | [] -> Monad.return Step.Done
      | l -> Monad.return (Step.Yields (l, []))
    in
    unfold ~init ~f

  let of_lists init =
    let f = function
      | [] -> Monad.return Step.Done
      | list :: rest -> Monad.return (Step.Yields (list, rest))
    in
    unfold ~init ~f

  let concat seq =
    let f = function
      | [], Sequence { state; f } -> (
        f state >>= function
        | Step.Done -> Monad.return Step.Done
        | Step.Skip state ->
          Monad.return @@ Step.Skip ([], Sequence { state; f })
        | Step.Yield (sub, state) ->
          Monad.return @@ Step.Skip ([ sub ], Sequence { state; f })
        | Step.Yields (subs, state) ->
          Monad.return @@ Step.Skip (subs, Sequence { state; f }))
      | Sequence { state; f } :: tail, next -> (
        f state >>= function
        | Step.Done -> Monad.return @@ Step.Skip (tail, next)
        | Step.Skip state ->
          Monad.return @@ Step.Skip (Sequence { state; f } :: tail, next)
        | Step.Yield (elt, state) ->
          Monad.return @@ Step.Yield (elt, (Sequence { state; f } :: tail, next))
        | Step.Yields (elts, state) ->
          Monad.return
          @@ Step.Yields (elts, (Sequence { state; f } :: tail, next)))
    in
    unfold ~init:([], seq) ~f

  let rec step (Sequence { state; f } as seq) =
    f state >>= function
    | Step.Done -> Monad.return ([], seq)
    | Step.Skip state | Step.Yields ([], state) -> step (Sequence { state; f })
    | Step.Yield (value, state) ->
      Monad.return ([ value ], Sequence { state; f })
    | Step.Yields (values, state) -> Monad.return (values, Sequence { state; f })

  include struct
    let rec fold_until (Sequence { state; f = step }) ~init ~f ~finish =
      let open Base.Container.Continue_or_stop in
      step state >>= function
      | Step.Done -> Monad.return (finish init)
      | Step.Skip state ->
        fold_until ~init ~f ~finish (Sequence { state; f = step })
      | Step.Yield (v, state) -> (
        match f init v with
        | Stop v -> Monad.return v
        | Continue init ->
          fold_until (Sequence { state; f = step }) ~f ~init ~finish)
      | Step.Yields (v, state) -> (
        let rec fold ~init ~f = function
          | [] -> Monad.return (Continue init)
          | hd :: tl -> (
            match f init hd with
            | Stop v -> Monad.return (Stop v)
            | Continue init -> fold ~init ~f tl)
        in
        fold ~init ~f v >>= function
        | Stop v -> Monad.return v
        | Continue init ->
          fold_until (Sequence { state; f = step }) ~init ~f ~finish)

    let fold seq ~init ~f =
      let open Base.Container.Continue_or_stop in
      fold_until seq ~init ~f:(fun init v -> Continue (f init v)) ~finish:Fn.id

    let folding_filter_map (Sequence { state; f = step }) ~init ~f =
      let f (acc, state) =
        step state >>= function
        | Step.Done -> Monad.return @@ Step.Done
        | Step.Skip state -> Monad.return @@ Step.Skip (acc, state)
        | Step.Yield (v, state) -> (
          match f acc v with
          | acc, Some v -> Monad.return @@ Step.Yield (v, (acc, state))
          | acc, None -> Monad.return @@ Step.Skip (acc, state))
        | Step.Yields (v, state) ->
          let rec filter acc l = function
            | [] -> (
              match l with
              | [] -> Monad.return @@ Step.Skip (acc, state)
              | _ -> Monad.return (Step.Yields (List.rev l, (acc, state))))
            | hd :: tl -> (
              match f acc hd with
              | acc, None -> filter acc l tl
              | acc, Some v -> filter acc (v :: l) tl)
          in
          filter acc [] v
      in
      Sequence { state = (init, state); f }

    let filter_map seq ~f =
      let f () v = ((), f v) in
      folding_filter_map seq ~init:() ~f

    let filter s ~f = filter_map s ~f:(fun e -> Option.some_if (f e) e)

    let folding_map s ~init ~f =
      folding_filter_map s ~init ~f:(fun acc v ->
          let acc, v = f acc v in
          (acc, Some v))

    let map s ~f = filter_map s ~f:(fun v -> Some (f v))

    let rec iter (Sequence { state; f = step }) ~f =
      step state >>= function
      | Step.Done -> Monad.return ()
      | Step.Skip state -> iter (Sequence { state; f = step }) ~f
      | Step.Yield (v, state) ->
        let () = f v in
        iter (Sequence { state; f = step }) ~f
      | Step.Yields (v, state) ->
        let () = List.iter ~f v in
        iter (Sequence { state; f = step }) ~f

    let find_map seq ~f =
      let open Base.Container.Continue_or_stop in
      let f () v =
        match f v with Some v -> Stop (Some v) | None -> Continue ()
      in
      fold_until seq ~init:() ~f ~finish:(fun () -> None)

    let find seq ~f = find_map seq ~f:(fun v -> Option.some_if (f v) v)

    let group_fold s ~init ~f =
      let f =
        let open Step in
        function
        | seq, (acc, (head :: tail as values)) -> (
          let rec loop acc = function
            | [] -> (acc, [])
            | head :: tail as values -> (
              match f acc head with
              | Some acc -> loop acc tail
              | None -> (acc, values))
          in
          let acc, values =
            match acc with
            | None -> (init head, tail)
            | Some acc -> (acc, values)
          in
          match loop acc values with
          | acc, [] -> Skip (seq, (Some acc, [])) |> Monad.return
          | acc, values -> Yield (acc, (seq, (None, values))) |> Monad.return)
        | seq, (acc, []) -> (
          step seq >>| function
          | [], next -> (
            match acc with
            | None -> Done
            | Some acc -> Yield (acc, (next, (None, []))))
          | values, next -> Skip (next, (acc, values)))
      in
      unfold ~init:(s, (None, [])) ~f
  end

  module Seq = struct
    let rec fold_until (Sequence { state; f = step }) ~init ~f ~finish =
      let open Base.Container.Continue_or_stop in
      step state >>= function
      | Step.Done -> Monad.return (finish init)
      | Step.Skip state ->
        fold_until ~init ~f ~finish (Sequence { state; f = step })
      | Step.Yield (v, state) -> (
        f init v >>= function
        | Stop v -> Monad.return v
        | Continue init ->
          fold_until (Sequence { state; f = step }) ~f ~init ~finish)
      | Step.Yields (v, state) -> (
        let rec fold ~init ~f = function
          | [] -> Monad.return (Continue init)
          | hd :: tl -> (
            f init hd >>= function
            | Stop v -> Monad.return (Stop v)
            | Continue init -> fold ~init ~f tl)
        in
        fold ~init ~f v >>= function
        | Stop v -> Monad.return v
        | Continue init ->
          fold_until (Sequence { state; f = step }) ~init ~f ~finish)

    let fold seq ~init ~f =
      let open Base.Container.Continue_or_stop in
      fold_until seq ~init
        ~f:(fun init v -> f init v >>| fun v -> Continue v)
        ~finish:Fn.id

    let folding_filter_map (Sequence { state; f = step }) ~init ~f =
      let f (acc, state) =
        step state >>= function
        | Step.Done -> Monad.return @@ Step.Done
        | Step.Skip state -> Monad.return @@ Step.Skip (acc, state)
        | Step.Yield (v, state) -> (
          f acc v >>= function
          | acc, Some v -> Monad.return @@ Step.Yield (v, (acc, state))
          | acc, None -> Monad.return @@ Step.Skip (acc, state))
        | Step.Yields (v, state) ->
          let rec filter acc l = function
            | [] -> (
              match l with
              | [] -> Monad.return @@ Step.Skip (acc, state)
              | _ -> Monad.return (Step.Yields (List.rev l, (acc, state))))
            | hd :: tl -> (
              f acc hd >>= function
              | acc, None -> filter acc l tl
              | acc, Some v -> filter acc (v :: l) tl)
          in
          filter acc [] v
      in
      Sequence { state = (init, state); f }

    let filter_map seq ~f =
      let f () v = Monad.map (f v) ~f:(fun v -> ((), v)) in
      folding_filter_map seq ~init:() ~f

    let filter s ~f =
      filter_map s ~f:(fun e ->
          f e >>| function true -> Some e | false -> None)

    let folding_map s ~init ~f =
      folding_filter_map s ~init ~f:(fun acc v ->
          f acc v >>| fun (acc, v) -> (acc, Some v))

    let map s ~f = filter_map s ~f:(fun v -> f v >>| Option.return)

    let rec iter (Sequence { state; f = step }) ~f =
      step state >>= function
      | Step.Done -> Monad.return ()
      | Step.Skip state -> iter (Sequence { state; f = step }) ~f
      | Step.Yield (v, state) ->
        f v >>= fun () -> iter (Sequence { state; f = step }) ~f
      | Step.Yields (v, state) ->
        let fold init v = init >>= fun () -> f v in
        List.fold ~init:(Monad.return ()) ~f:fold v >>= fun () ->
        iter (Sequence { state; f = step }) ~f

    let find_map seq ~f =
      let open Base.Container.Continue_or_stop in
      let f () v =
        f v >>| function Some v -> Stop (Some v) | None -> Continue ()
      in
      fold_until seq ~init:() ~f ~finish:(fun () -> None)

    let find seq ~f =
      find_map seq ~f:(fun v ->
          f v >>= function
          | true -> Monad.return @@ Some v
          | false -> Monad.return None)

    let group_fold s ~init ~f =
      let f =
        let open Step in
        function
        | seq, (None, value :: rest) ->
          init value >>| fun value -> Skip (seq, (Some value, rest))
        | seq, (Some acc, value :: rest) -> (
          f acc value >>= function
          | Some value -> Monad.return (Skip (seq, (Some value, rest)))
          | None ->
            init value >>| fun value -> Yield (acc, (seq, (Some value, rest))))
        | seq, (acc, []) -> (
          step seq >>| function
          | [], next -> (
            match acc with
            | None -> Done
            | Some acc -> Yield (acc, (next, (None, []))))
          | values, next -> Skip (next, (acc, values)))
      in
      unfold ~init:(s, (None, [])) ~f
  end

  let to_list_rev seq =
    let rec to_list_rev acc seq =
      step seq >>= function
      | [], _ -> Monad.return acc
      | l, seq -> to_list_rev (List.rev_append l acc) seq
    in
    to_list_rev [] seq

  let to_list seq = to_list_rev seq >>| List.rev

  let partition_rev seq =
    let rec loop (l, r) seq =
      step seq >>= function
      | [], _ -> Monad.return (l, r)
      | v, sequence ->
        let acc =
          let f (l, r) = function
            | Either.First h -> (h :: l, r)
            | Either.Second h -> (l, h :: r)
          in
          List.fold_left v ~init:(l, r) ~f
        in
        loop acc sequence
    in
    loop ([], []) seq

  let partition seq =
    partition_rev seq >>| fun (l, r) -> (List.rev l, List.rev r)

  let head seq = step seq >>| function [], _ -> None | hd :: _, _ -> Some hd
  let length seq = Seq.fold seq ~init:0 ~f:(fun i _ -> Monad.return (i + 1))
end

module Make (Monad : Base.Monad.S) = struct
  module Monad2 = struct
    type ('a, 'b) t = 'a Monad.t

    module Step = Step

    include Base.Monad.Make2 (struct
      include Monad

      type nonrec ('a, 'b) t = 'a Monad.t

      let map = `Custom map
    end)
  end

  include Make2 (Monad2)

  type nonrec 'a t = ('a, unit) t
end
