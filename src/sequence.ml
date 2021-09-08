open Base
module Step = Base.Sequence.Step

module Make2 (Monad : Base.Monad.S2) = struct
  open Monad
  module Step = Base.Sequence.Step

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
    let f s = Monad.return @@ Base.Sequence.Expert.next_step s in
    unfold ~init ~f

  let of_list init =
    let f = function
      | hd :: tl -> Monad.return @@ Some (hd, tl)
      | [] -> Monad.return None
    in
    unfold_step ~init ~f

  let concat seq =
    let f = function
      | None, Sequence { state; f } -> (
        f state >>= function
        | Step.Done -> Monad.return Step.Done
        | Step.Skip state ->
          Monad.return @@ Step.Skip (None, Sequence { state; f })
        | Step.Yield (sub, state) ->
          Monad.return @@ Step.Skip (Some sub, Sequence { state; f }))
      | Some (Sequence { state; f }), next -> (
        f state >>= function
        | Step.Done -> Monad.return @@ Step.Skip (None, next)
        | Step.Skip state ->
          Monad.return @@ Step.Skip (Some (Sequence { state; f }), next)
        | Step.Yield (elt, state) ->
          Monad.return @@ Step.Yield (elt, (Some (Sequence { state; f }), next))
        )
    in
    unfold ~init:(None, seq) ~f

  let rec fold_left (Sequence { state; f = step }) ~f ~init =
    step state >>= function
    | Step.Done -> Monad.return init
    | Step.Skip state -> fold_left (Sequence { state; f = step }) ~f ~init
    | Step.Yield (v, state) ->
      f init v >>= fun init -> fold_left (Sequence { state; f = step }) ~f ~init

  let filter_map :
      type from to_.
      (from, 'b) t -> f:(from -> (to_ option, 'b) Monad.t) -> (to_, 'b) t =
   fun (Sequence { state; f = step }) ~f ->
    let f state =
      step state >>= function
      | Step.Yield (v, state) -> (
        f v >>= function
        | Some v -> Monad.return @@ Step.Yield (v, state)
        | None -> Monad.return @@ Step.Skip state)
      | Step.Skip state -> Monad.return @@ Step.Skip state
      | Step.Done -> Monad.return @@ Step.Done
    in
    Sequence { state; f }

  let filter s ~f =
    filter_map s ~f:(fun e ->
        f e >>| function
        | true -> Some e
        | false -> None)

  let map s ~f = filter_map s ~f:(fun v -> f v >>| Option.return)

  let rec iter (Sequence { state; f = step }) ~f =
    step state >>= function
    | Step.Done -> Monad.return ()
    | Step.Skip state -> iter (Sequence { state; f = step }) ~f
    | Step.Yield (v, state) ->
      f v >>= fun () -> iter (Sequence { state; f = step }) ~f

  let rec to_list (Sequence { state; f }) =
    f state >>= function
    | Step.Done -> Monad.return []
    | Step.Skip state -> to_list (Sequence { state; f })
    | Step.Yield (v, state) ->
      to_list (Sequence { state; f }) >>| fun tail -> v :: tail

  let rec step (Sequence { state; f } as seq) =
    f state >>= function
    | Step.Done -> Monad.return (None, seq)
    | Step.Skip state -> step (Sequence { state; f })
    | Step.Yield (v, state) -> Monad.return (Some v, Sequence { state; f })

  let rec partition seq =
    step seq >>= function
    | None, _ -> Monad.return ([], [])
    | Some v, sequence -> (
      partition sequence >>| fun (l, r) ->
      match v with
      | Either.First h -> (h :: l, r)
      | Either.Second h -> (l, h :: r))

  let head seq = step seq >>| fst

  let rec find_map seq ~f =
    step seq >>= function
    | None, _ -> Monad.return None
    | Some value, seq -> (
      f value >>= function
      | Some value -> Monad.return @@ Some value
      | None -> find_map ~f seq)

  let find seq ~f =
    find_map seq ~f:(fun v ->
        f v >>= function
        | true -> Monad.return @@ Some v
        | false -> Monad.return None)

  let rec fold seq ~init ~f =
    step seq >>= function
    | Some v, seq -> f init v >>= fun init -> fold seq ~init ~f
    | None, _ -> Monad.return init

  let length seq = fold seq ~init:0 ~f:(fun i _ -> Monad.return (i + 1))
end

module Make (Monad : Base.Monad.S) = struct
  module Monad2 = struct
    type ('a, 'b) t = 'a Monad.t

    include Base.Monad.Make2 (struct
      include Monad

      type nonrec ('a, 'b) t = 'a Monad.t

      let map = `Custom map
    end)
  end

  include Make2 (Monad2)

  type nonrec 'a t = ('a, unit) t
end
