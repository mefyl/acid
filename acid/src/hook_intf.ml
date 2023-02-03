open Base

module Interface (T : sig
  type ('payload, 'value, 'value_monad, 'result, 'result_monad, 'witness) t
end) =
struct
  module Expert = struct
    type ('payload, 'value, 'value_monad, 'result, 'result_monad, 'witness) t =
      ('payload, 'value, 'value_monad, 'result, 'result_monad, 'witness) T.t

    module type RES = sig
      type value
      type result

      val reduce : result -> value -> result
    end

    module type S2 = sig
      (** A [witness] uniquely identifies a subscription to a hook. *)
      type witness

      module Monad : Monad.S2
      module Res : RES

      (** A ['a t] is a hook using [witness] as witnesses. *)
      type nonrec ('payload, 'b) t =
        ( 'payload,
          Res.value,
          (Res.value, 'b) Monad.t,
          Res.result,
          (Res.result, 'b) Monad.t,
          witness )
        T.t

      (** [empty] is a hook that invokes no callbacks. *)
      val empty : ('payload, 'b) t
    end

    module type S = sig
      (** A [witness] uniquely identifies a subscription to a hook. *)
      type witness

      module Monad : Monad.S
      module Res : RES

      (** A ['a t] is a hook using [witness] as witnesses. *)
      type nonrec 'payload t =
        ( 'payload,
          Res.value,
          Res.value Monad.t,
          Res.result,
          Res.result Monad.t,
          witness )
        T.t

      (** [empty] is a hook that invokes no callbacks. *)
      val empty : 'payload t
    end
  end

  module type S = sig
    (** A [witness] uniquely identifies a subscription to a hook. *)
    type witness

    (** A ['a t] is a hook using [witness] as witnesses. *)
    type 'payload t = ('payload, unit, unit, unit, unit, witness) Expert.t

    (** [empty] is a hook that invokes no callbacks. *)
    val empty : 'payload t
  end

  type ('payload, 'witness) t =
    ('payload, unit, unit, unit, unit, 'witness) Expert.t
end
