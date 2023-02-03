(** Tickers call a function periodically. *)

include module type of Ticker_intf

module Make (Time : sig
  val now : unit -> Timmy.Time.t
  val sleep : float -> unit Lwt.t
end) : S
