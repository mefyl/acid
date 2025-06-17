(** A lighteweight tracing mechanism based on the
    {{:https://ocaml.org/p/trace/latest} Trace} library. *)

(** Run the given expression, tracing its execution time.

    This doesn't take any form of concurrency into account.

    For tracing computations in a monadic-based concurrency, use {!Monadic}. For
    non-monadic concurrency, use {!Expert.start} and {!Expert.end}. *)
val run : ?here:Lexing.position -> string -> (unit -> 'a) -> 'a

(** Similar to [run], but allow passing an argument to the function to trace *)
val runf : ?here:Lexing.position -> string -> ('a -> 'b) -> 'a -> 'b

module Expert : sig
  type t

  val start : ?here:Lexing.position -> string -> t
  val end' : t -> unit
end

(**
  A {{ :https://docs.google.com/document/d/1CvAClvFfyA5R-PhYUmn5OOQtYMH4h6I0nSsKchNAySU/edit?tab=t.0#heading=h.yr4qxyxotyw }TEF} backend for the logs.

  It is disabled by default, but can be enabled with the `set_target` function.    
*)
module Tef : sig
  module Writer : sig
    (** Set the target to which the TEF trace will be written for the
        application bench *)
    val set_target :
      [< `Formatter of Format.formatter | `Stderr | `Channel of out_channel ] ->
      unit

    (** Automatically enable the TEF tracing based on the value of
        [$ACID_BENCH_TEF_TARGET]:

        - If it is set to ["stderr"], sets the target to [stderr]
        - If set to anything else, set the target to a file with that name
        - If unset, disable TEF tracing *)
    val auto : unit -> unit

    (** Disable the TEF tracing *)
    val disable : unit -> unit
  end
end

(** Specialized version to take into account monadic concurrency.

    See {!Acid_lwt.Bench} *)
module Monadic : functor (M : Monad.S) -> sig
  (** Run the given expression, tracing its execution time *)
  val run : ?here:Lexing.position -> string -> (unit -> 'a M.t) -> 'a M.t

  (** Similar to [run], but allow passing an argument to the function to trace
  *)
  val runf : ?here:Lexing.position -> string -> ('a -> 'b M.t) -> 'a -> 'b M.t
end
