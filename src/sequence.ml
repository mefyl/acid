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

  let unfold ~init ~f = Sequence { state = init; f }

  let unfold_step ~init ~f =
    let f s =
      f s >>| function
      | Some (s, state) -> Step.Yield (s, state)
      | None -> Step.Done
    in
    Sequence { state = init; f }

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
          Monad.return @@ Step.Skip (Some sub, Sequence { state; f }) )
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

  let head seq = step seq >>| fst
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
