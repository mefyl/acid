open Base

let logs_src = Logs.Src.create "Acid_bench"

module Log = (val Logs.src_log logs_src)

module Tef = struct
  type event = {
    name : string;
    ts : float; (* Start time, in us *)
    dur : float; (* Duration, in us *)
    pid : int;
    tid : int;
  }

  (* Shamelessely copied from
     https://github.com/c-cube/ocaml-trace/blob/main/src/tef/writer.ml *)
  let str_val (fmt : Stdlib.Format.formatter) (s : string) =
    let char = Fmt.char in
    let raw_string = Fmt.string in
    char fmt '"';
    let encode_char c =
      match c with
      | '"' -> raw_string fmt {|\"|}
      | '\\' -> raw_string fmt {|\\|}
      | '\n' -> raw_string fmt {|\n|}
      | '\b' -> raw_string fmt {|\b|}
      | '\r' -> raw_string fmt {|\r|}
      | '\t' -> raw_string fmt {|\t|}
      | _ when Char.to_int c <= 0x1f ->
        raw_string fmt {|\u00|};
        Fmt.pf fmt "%02x" (Char.to_int c)
      | c -> char fmt c
    in
    String.iter ~f:encode_char s;
    char fmt '"'

  let dump fmt t =
    Fmt.pf fmt
      {| {"pid":%d,"cat":"","tid": %d,"dur": %.2f,"ts": %.2f,"name":%a,"ph":"X"},@. |}
      t.pid t.tid t.dur t.ts str_val t.name

  module Writer = struct
    type target = Stdlib.Format.formatter option

    let target : target ref = ref None

    let set_target t =
      let new_target =
        match t with
        | `Formatter fmt -> fmt
        | `Stderr -> Fmt.stderr
        | `Channel out_chan -> Stdlib.Format.formatter_of_out_channel out_chan
      in
      let () = target := Some new_target in
      Fmt.string new_target "["

    let disable () = target := None

    let auto () =
      match Sys.getenv "ACID_BENCH_TEF_TARGET" with
      | None -> disable ()
      | Some "stderr" -> set_target `Stderr
      | Some fname ->
        (* This leaks the channel, but it is assumed that it will stay open for
           the whole duration of the app any way, so it shouldn't matter in
           practice *)
        set_target @@ `Channel (Stdlib.open_out_bin fname)

    let write event =
      match !target with None -> () | Some fmt -> dump fmt event
  end
end

module Expert = struct
  type t = {
    name : string;
    pos : Lexing.position option;
    start : Timmy.Time.t;
  }

  let program_start = Ptime_clock.now () |> Timmy.Time.of_ptime

  let span_to_us span =
    let days, ps = Ptime.Span.to_d_ps @@ Timmy.Span.to_ptime span in
    if days > 0 then
      Logs.warn (fun m ->
          m "Integer overflow converting the span %a to microseconds"
            Timmy.Span.pp span);
    Int64.(to_float @@ (ps / 1_000_000L))

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
    let now = now () in
    let dur = span_to_us @@ Timmy.Time.(now - start) in
    let ts = span_to_us @@ Timmy.Time.(start - program_start) in
    Tef.Writer.write { name; pid = 0; tid = 0; ts; dur };
    Log.info (fun m ->
        m "bench %s: %a" ~tags name Timmy.Span.pp Timmy.Time.(now - start))
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
