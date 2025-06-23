let logs_src = Logs.Src.create "Acid_bench"

module Log = (val Logs.src_log logs_src)

module Expert = struct
  type t = {
    name : string;
    pos : Lexing.position option;
    start : Timmy.Time.t;
  }

  let pos_tag : Lexing.position Logs.Tag.def =
    let pp_position fmt { Lexing.pos_fname; pos_lnum; _ } =
      Fmt.pf fmt "%s:%d" pos_fname pos_lnum
    in
    Logs.Tag.def ~doc:"The position at which the log was sent" "position"
      pp_position

  let now () = Ptime_clock.now () |> Timmy.Time.of_ptime
  let start ?here name = { name; start = now (); pos = here }

  let end' { name; start; pos } =
    let tags =
      match pos with
      | None -> Logs.Tag.empty
      | Some pos -> Logs.Tag.(add pos_tag pos empty)
    in
    Log.info (fun m ->
        m "bench %s: %a" ~tags name Timmy.Span.pp Timmy.Time.(now () - start))
end

module Monadic (M : Monad.S) = struct
  let runf ?here name f arg =
    let open Let.Syntax (M) in
    let bench = Expert.start ?here name in
    let+ res = f arg in
    let () = Expert.end' bench in
    res

  let run ?here name f = runf ?here name f ()
end

include Monadic (Monad.Ident)
