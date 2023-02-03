module Hook = Hook.Make ()
include Ticker_intf

(* There is room for additional features like stopping, pausing, ... *)

module Make (Time : sig
  val now : unit -> Timmy.Time.t
  val sleep : float -> unit Lwt.t
end) =
struct
  type t = {
    f : Timmy.Time.t -> bool;
    immediate : bool;
    period : Timmy.Span.t;
    mutable running : bool;
    stop : unit Lwt_mvar.t;
  }

  let start ?start ({ f; immediate; period; stop; _ } as t) =
    let open Let.Syntax (Acid_lwt) in
    let start = match start with None -> Time.now () | Some start -> start in
    if not t.running then
      let () = t.running <- true in
      let rec tick immediate time =
        let now = Time.now () in
        let* run =
          let delay =
            Timmy.Time.(time - now)
            |> Timmy.Span.to_ptime |> Ptime.Span.to_float_s
          in
          Lwt.choose
            [
              (Time.sleep delay >>| fun () -> true);
              (Lwt_mvar.take stop >>| fun () -> false);
            ]
        in
        if run then
          let next = if immediate then f time else true in
          if next then tick true Timmy.Time.(time + period) else Lwt.return ()
        else Lwt.return ()
      in
      Lwt.async (fun () -> tick immediate start)

  let stop t =
    if t.running then
      let () = t.running <- false in
      Lwt.async (fun () -> Lwt_mvar.put t.stop ())

  let make ?(immediate = true) ?start:start_time ~period f =
    let res =
      { f; immediate; period; running = false; stop = Lwt_mvar.create_empty () }
    in
    let () =
      match start_time with
      | None -> start res
      | Some (Some start_time) -> start ~start:start_time res
      | Some None -> ()
    in
    res
end
