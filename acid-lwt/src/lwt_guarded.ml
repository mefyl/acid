type 'a t = {
  guard : Lwt_mutex.t;
  value : 'a;
}

let acquire { guard; value } ~f = Lwt_mutex.with_lock guard (fun () -> f value)
let make value = { guard = Lwt_mutex.create (); value }
let is_locked { guard; _ } = Lwt_mutex.is_locked guard
let is_empty { guard; _ } = Lwt_mutex.is_empty guard
