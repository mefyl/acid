module Make (S : sig
  type t
end) =
struct
  type t = S.t
  type _ Effect.t += Change : (t -> t) -> t Effect.t

  let change f = Effect.perform (Change f)

  let change_unit f =
    let (_ : t) = Effect.perform (Change f) in
    ()

  let put v = Effect.perform (Change (fun _ -> v))

  type _ Effect.t += Get : t Effect.t

  let get () = Effect.perform Get

  let run_state init f =
    let rec handle :
        'arg. t -> ('arg, 'res) Effect.Shallow.continuation -> 'arg -> 'res * t
        =
     fun (type arg) (state : t) (k : (arg, 'res) Effect.Shallow.continuation)
         (arg : arg) ->
      Effect.Shallow.continue_with k arg
        {
          retc = (fun v -> (v, state));
          exnc = raise;
          effc =
            (fun (type eff) (eff : eff Effect.t) ->
              match eff with
              | Get ->
                Some
                  (fun (k : (eff, _) Effect.Shallow.continuation) ->
                    handle state k state)
              | Change f ->
                Some
                  (fun (k : (eff, _) Effect.Shallow.continuation) ->
                    handle (f state) k state)
              | _ -> None);
        }
    in
    handle init (Effect.Shallow.fiber f) ()

  let run init f = run_state init f |> fst
end
