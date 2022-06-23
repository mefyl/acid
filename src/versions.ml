(** Backward compatibility versions *)

module V0_7_0 = struct
  (** @closed *)
  include Base

  module Array = Root.Array
  module Hlist = Hlist
  module IQueue = Root.Queue
  module Let = Let
  module Lwt = Root.Lwt
  module Lwt_result = Root.Lwt_result
  module Lwt_guarded = Lwt_guarded
  module Mode = Mode
  module Result = Root.Result
  module Sequence = Root.Sequence
  module Split = Split

  module List_nonempty : sig
    open Base
    include module type of Select.List_nonempty

    val rev : 'a t -> 'a t
    val append : 'a t -> 'a t -> 'a t
    val concat : 'a t t -> 'a t
    val cons : 'a -> 'a t -> 'a t
    val filter : 'a t -> f:('a -> bool) -> 'a List.t
    val fold : 'a t -> f:('a -> 'a -> 'a) -> 'a
    val map : 'a t -> f:('a -> 'b) -> 'b t
    val mapi : 'a t -> f:('a -> int -> 'b) -> 'b t
    val filter_map : 'a t -> f:('a -> 'b option) -> 'b List.t
    val rev_mapi : 'a t -> f:('a -> int -> 'b) -> 'b t
    val sort : 'a t -> compare:('a -> 'a -> int) -> 'a t
    val stable_sort : 'a t -> compare:('a -> 'a -> int) -> 'a t
    val hd : 'a t -> 'a
    val tl : 'a t -> 'a List.t
    val to_list : 'a t -> 'a List.t
    val of_list : 'a List.t -> 'a t option
    val of_list_exn : 'a List.t -> 'a t
    val lift : ('a List.t -> 'b List.t) -> 'a t -> 'b t option
    val lift_exn : ('a List.t -> 'b List.t) -> 'a t -> 'b t
    val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool
    val pp : ?sep:unit Fmt.t -> 'a Fmt.t -> 'a t Fmt.t
  end = struct
    include List_nonempty

    let mapi l ~f = mapi l ~f:(fun v i -> f i v)
  end
end

module V0_7_1 = V0_7_0

module V0_7_2 = struct
  (** @closed *)
  include Base

  module Array = Root.Array
  module Hlist = Hlist
  module IQueue = Root.Queue
  module Let = Let
  module Lwt = Root.Lwt
  module Lwt_result = Root.Lwt_result
  module Lwt_guarded = Lwt_guarded
  module Mode = Mode
  module Result = Root.Result
  module Sequence = Root.Sequence
  module Split = Split
  module List_nonempty = List_nonempty
end

module V0_7_3 = struct
  (** @closed *)
  include V0_7_2

  module Either = Root.Either
end
