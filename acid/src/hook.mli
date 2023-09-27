(** Hooks are valued signals that can be subscribed to.

    Hooks have a witness type parameter to ensure subscriptions id from a hook
    cannot be used with another hook. The [Make] functor generates such a
    witness. *)

(** A ['a t] is a hook carrying values of type ['a]. *)
type ('payload, 'value, 'value_monad, 'result, 'result_monad, 'witness) expert

include module type of Hook_intf.Interface (struct
  type nonrec ('payload,
                'value,
                'value_monad,
                'result,
                'result_monad,
                'witness)
              t =
    ('payload, 'value, 'value_monad, 'result, 'result_monad, 'witness) expert
end)

module Expert : sig
  include module type of Expert

  module Make2
      (Monad : Base.Monad.S2)
      (Res : sig
        type value
        type result

        val reduce : result -> value -> result
      end) : S2

  module Make
      (Monad : Base.Monad.S)
      (Res : sig
        type value
        type result

        val reduce : result -> value -> result
      end) : S
end

module Make () : S

(** [attach hook callback] returns [(new_hook, witness)] where:

    - [new_hook] is a hook that invokes [callback] then all callbacks registered
      in [hook].
    - [witness] is the unique subscription id for this callback. *)
val attach :
  (('payload, _, 'value, _, _, 'witness) Expert.t as 'hook) ->
  ('payload -> 'value) ->
  'hook * 'witness

(** [attach_witness] is like [attach] except the callback is passed the
    subscription witness. Use it if you need to call [detach] for the callback. *)
val attach_witness :
  (('payload, _, 'value, _, _, 'witness) Expert.t as 'hook) ->
  ('witness -> 'payload -> 'value) ->
  'hook * 'witness

(** [detach hook witness] is a hook that invokes all callbacks of [hook] except
    the one whose registration returned [witness]. *)
val detach : ((_, _, _, _, _, 'witness) Expert.t as 'hook) -> 'witness -> 'hook

(** [trigger hook payload] invokes [hook] callbacks passing them [payload]. *)
val trigger :
  ('payload, _, _, 'result, 'result_monad, _) Expert.t ->
  'payload ->
  'result ->
  'result_monad
