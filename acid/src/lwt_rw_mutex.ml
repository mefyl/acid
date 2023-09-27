open Let.Syntax (Acid_lwt)

type t = {
  condition : unit Lwt_condition.t;
  name : string option;
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
let make ?name () = { condition = Lwt_condition.create (); name; state = Free }
let state { state; _ } = state

let rec protect t ?reason acquire release f =
  if acquire ?reason t then
    Lwt.catch
      (fun () ->
        let+ res = f () in
        let () =
          if release ?reason t then Lwt_condition.broadcast t.condition ()
        in
        res)
      (fun e ->
        let () =
          if release ?reason t then Lwt_condition.broadcast t.condition ()
        in
        raise e)
  else
    let* () = Lwt_condition.wait t.condition in
    protect t ?reason acquire release f

let rec _lock t acquire =
  if acquire t then Lwt.return ()
  else
    let* () = Lwt_condition.wait t.condition in
    _lock t acquire

let _release t release =
  if release t then Lwt_condition.broadcast t.condition ()

let pp_reason = Fmt.(option (const string ": " ++ string))

let acquire_read ?reason t =
  match t.state with
  | Free ->
    let () =
      match t.name with
      | None -> ()
      | Some name ->
        Acid_logs.info (fun m ->
            m "%s: acquire for reading%a" name pp_reason reason)
    in
    let () = t.state <- Reading 1 in
    true
  | Reading n ->
    let () =
      match t.name with
      | None -> ()
      | Some name ->
        Acid_logs.info (fun m ->
            m "%s: acquire additionally for reading%a" name pp_reason reason)
    in
    let () = t.state <- Reading (n + 1) in
    true
  | Writing ->
    let () =
      match t.name with
      | None -> ()
      | Some name ->
        Acid_logs.info (fun m ->
            m "%s: block acquiring for reading%a" name pp_reason reason)
    in
    false

and release_read ?reason t =
  match t.state with
  | Reading 1 ->
    let () =
      match t.name with
      | None -> ()
      | Some name ->
        Acid_logs.info (fun m ->
            m "%s: release  for reading%a" name pp_reason reason)
    in
    let () = t.state <- Free in
    true
  | Reading n ->
    let () =
      match t.name with
      | None -> ()
      | Some name ->
        Acid_logs.info (fun m ->
            m "%s: release partially for reading%a" name pp_reason reason)
    in
    let () = t.state <- Reading (n - 1) in
    false
  | _ -> failwith "invalid read-releasing a rw-mutex locked for writing"

let read t ?reason f = protect t ?reason acquire_read release_read f
let lock_read t = _lock t acquire_read
let release_read t = _release t release_read

let acquire_write ?reason t =
  match t.state with
  | Free ->
    let () =
      match t.name with
      | None -> ()
      | Some name ->
        Acid_logs.info (fun m ->
            m "%s: acquire for writing%a" name pp_reason reason)
    in
    let () = t.state <- Writing in
    true
  | state ->
    let () =
      match t.name with
      | None -> ()
      | Some name ->
        Acid_logs.info (fun m ->
            m "%s: block acquiring for writing%a: %a" name pp_reason reason
              pp_state state)
    in
    false

and release_write ?reason t =
  match t.state with
  | Writing ->
    let () =
      match t.name with
      | None -> ()
      | Some name ->
        Acid_logs.info (fun m ->
            m "%s: release for writing%a" name pp_reason reason)
    in
    let () = t.state <- Free in
    true
  | _ -> failwith "write-releasing a rw-mutex not locked for writing"

let write t ?reason f = protect ?reason t acquire_write release_write f
let lock_write t = _lock t acquire_write
let release_write t = _release t release_write
