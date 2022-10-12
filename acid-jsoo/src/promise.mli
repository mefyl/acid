type 'a t

val all : 'a t Array.t Js_of_ocaml.Js.t -> 'a t
val choose : 'a t Array.t Js_of_ocaml.Js.t -> 'a t
val return : 'a -> 'a t
val to_lwt : 'a t -> 'a Lwt.t
val of_lwt : (unit -> 'a Lwt.t) -> 'a t

val of_lwt_result :
  error:('error -> 'rejected) -> (unit -> ('a, 'error) Lwt_result.t) -> 'a t
