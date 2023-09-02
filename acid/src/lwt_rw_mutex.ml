open Let.Syntax (Acid_lwt)

type t = {
  condition : unit Lwt_condition.t;
  mutable state : state;
}

and state =
  | Free
  | Reading of int
  | Writing

let pp_state f = function
  | Free -> Fmt.string f "free"
  | Reading n -> Fmt.pf f "reading %d times" n
  | Writing -> Fmt.string f "writing"

let show_state = Fmt.to_to_string pp_state
let make () = { condition = Lwt_condition.create (); state = Free }
let state { state; _ } = state

let rec protect t acquire release f =
  if acquire t then
    Lwt.catch
      (fun () ->
        let+ res = f () in
        let () = if release t then Lwt_condition.broadcast t.condition () in
        res)
      (fun e ->
        let () = if release t then Lwt_condition.broadcast t.condition () in
        raise e)
  else
    let* () = Lwt_condition.wait t.condition in
    protect t acquire release f

let rec _lock t acquire =
  if acquire t then Lwt.return ()
  else
    let* () = Lwt_condition.wait t.condition in
    _lock t acquire

let _release t release =
  if release t then Lwt_condition.broadcast t.condition ()

let acquire_read t =
  match t.state with
  | Free ->
    let () = t.state <- Reading 1 in
    true
  | Reading n ->
    let () = t.state <- Reading (n + 1) in
    true
  | Writing -> false

and release_read t =
  match t.state with
  | Reading 1 ->
    let () = t.state <- Free in
    true
  | Reading n ->
    let () = t.state <- Reading (n - 1) in
    false
  | _ -> failwith "invalid read-releasing a rw-mutex locked for writing"

let read t f = protect t acquire_read release_read f
let lock_read t = _lock t acquire_read
let release_read t = _release t release_read

let acquire_write t =
  match t.state with
  | Free ->
    let () = t.state <- Writing in
    true
  | _ -> false

and release_write t =
  match t.state with
  | Writing ->
    let () = t.state <- Free in
    true
  | _ -> failwith "write-releasing a rw-mutex locked for writing"

let write t f = protect t acquire_write release_write f
let lock_write t = _lock t acquire_write
let release_write t = _release t release_write
