open Base

type ('payload, 'value, 'value_monad, 'result, 'result_monad, 'witness) expert = {
  callbacks : (int, 'payload -> 'value_monad, Int.comparator_witness) Map.t;
  make_witness : unit -> 'witness;
  monad_bind : 'value_monad -> ('value -> 'result_monad) -> 'result_monad;
  monad_return : 'result -> 'result_monad;
  reduce : 'result_monad -> 'value -> 'result_monad;
  witness_to_int : 'witness -> int;
}

include Hook_intf.Interface (struct
  type nonrec ('payload,
                'value,
                'value_monad,
                'result,
                'result_monad,
                'witness)
              t =
    ('payload, 'value, 'value_monad, 'result, 'result_monad, 'witness) expert
end)

module Expert = struct
  include Expert

  module Make2 (Monad : Monad.S2) (Res : RES) = struct
    type witness = < >

    module Monad = Monad
    module Res = Res

    type nonrec ('payload, 'b) t =
      ( 'payload,
        Res.value,
        (Res.value, 'b) Monad.t,
        Res.result,
        (Res.result, 'b) Monad.t,
        witness )
      t

    let callbacks = Map.empty (module Int)

    let empty : ('a, 'b) t =
      {
        monad_bind = (fun v f -> Monad.bind v ~f);
        monad_return = Monad.return;
        callbacks;
        make_witness = (fun () -> object end);
        reduce =
          (fun acc value -> Monad.map acc ~f:(fun acc -> Res.reduce acc value));
        witness_to_int = Stdlib.Oo.id;
      }
  end

  module Make (Monad_ : Monad.S) (Res : RES) = struct
    include
      Make2
        (struct
          type ('a, 'b) t = 'a Monad_.t

          include (Monad_ : Base.Monad.S with type 'a t := 'a Monad_.t)
        end)
        (Res)

    module Monad = Monad_
    module Res = Res

    type nonrec 'a t = ('a, unit) t
  end
end

module Make () = struct
  include
    Expert.Make
      (Monad.Ident)
      (struct
        type result = unit
        type value = unit

        let reduce () () = ()
      end)

  type nonrec 'payload t = ('payload, unit, unit, unit, unit, witness) Expert.t
end

let attach ({ callbacks; make_witness; witness_to_int; _ } as t) data =
  let sub = make_witness () in
  ({ t with callbacks = Map.set ~key:(witness_to_int sub) ~data callbacks }, sub)

let attach_witness ({ callbacks; make_witness; witness_to_int; _ } as t) data =
  let sub = make_witness () in
  ( {
      t with
      callbacks = Map.set ~key:(witness_to_int sub) ~data:(data sub) callbacks;
    },
    sub )

let detach ({ callbacks; witness_to_int; _ } as t) sub =
  { t with callbacks = Map.remove callbacks (witness_to_int sub) }

let trigger (type a b c d e f)
    ({ callbacks; monad_bind; reduce; monad_return; _ } :
      (a, b, c, d, e, f) Expert.t) v init =
  Map.fold ~init:(monad_return init)
    ~f:(fun ~key:_ ~data acc -> monad_bind (data v) (reduce acc))
    callbacks
