open Acid
open Js_of_ocaml

type 'a promise
type 't t = 't promise Js.t

let _Promise = Js.Unsafe.global##._Promise

let _catch (p : 'a promise Js.t) (f : _ -> 'a promise Js.t) : 'a promise Js.t =
  (Js.Unsafe.coerce p)##_catch (Js.wrap_callback f)

let _then (p : 'a promise Js.t) ?(catch : (_ -> 'b promise Js.t) option)
    (f : 'a -> 'b promise Js.t) : 'b promise Js.t =
  match catch with
  | None -> (Js.Unsafe.coerce p)##_then (Js.wrap_callback f)
  | Some catch ->
    (Js.Unsafe.coerce p)##_then (Js.wrap_callback f) (Js.wrap_callback catch)

let return (v : 'a) : 'a promise Js.t =
  Js.Unsafe.meth_call _Promise "resolve" [| Js.Unsafe.inject v |]

let choose (promise_list : 'a promise Js.t Js.js_array Js.t) : 'a promise Js.t =
  Js.Unsafe.meth_call _Promise "race" [| Js.Unsafe.inject promise_list |]

let all (promise_list : 'a promise Js.t Js.js_array Js.t) : 'a promise Js.t =
  Js.Unsafe.meth_call _Promise "all" [| Js.Unsafe.inject promise_list |]

let to_lwt p =
  let res, resolve = Lwt.wait () in
  let _ = _then p (fun v -> return @@ Lwt.wakeup resolve v) in
  res

let of_lwt p =
  let open Let.Syntax2 (Lwt_result) in
  new%js _Promise
    (Js.wrap_callback (fun resolve reject ->
         let ( >>= ) = Lwt.( >>= ) in
         let p =
           Lwt.catch p (fun e ->
               let msg = Caml.Printexc.to_string e in
               Js.Unsafe.fun_call reject
                 [| Js.Unsafe.inject (new%js Js.error_constr (Js.string msg)) |])
         in
         p >>= function
         | v ->
           Lwt.return @@ Js.Unsafe.fun_call resolve [| Js.Unsafe.inject v |]))

let of_lwt_result ~error p =
  let open Let.Syntax2 (Lwt_result) in
  new%js _Promise
    (Js.wrap_callback (fun resolve reject ->
         let ( >>= ) = Lwt.( >>= ) in
         let p =
           Lwt.catch p (fun e ->
               let msg = Caml.Printexc.to_string e in
               Js.Unsafe.fun_call reject
                 [| Js.Unsafe.inject (new%js Js.error_constr (Js.string msg)) |])
         in
         p >>= function
         | Result.Ok v ->
           Lwt.return @@ Js.Unsafe.fun_call resolve [| Js.Unsafe.inject v |]
         | Result.Error e ->
           Lwt.return
           @@ Js.Unsafe.fun_call reject [| Js.Unsafe.inject @@ error e |]))
