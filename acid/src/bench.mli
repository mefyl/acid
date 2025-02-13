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

(** Specialized version to take into account monadic concurrency.

    See {!Acid_lwt.Bench} *)
module Monadic : functor (M : Monad.S) -> sig
  (** Run the given expression, tracing its execution time *)
  val run : ?here:Lexing.position -> string -> (unit -> 'a M.t) -> 'a M.t

  (** Similar to [run], but allow passing an argument to the function to trace *)
  val runf : ?here:Lexing.position -> string -> ('a -> 'b M.t) -> 'a -> 'b M.t
end
