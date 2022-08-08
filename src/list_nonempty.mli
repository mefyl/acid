open Base
include module type of Select.List_nonempty
include Container.S1 with type 'a t := 'a t

(** {0 Functions that differ from Container} *)

val min_elt : 'a t -> compare:('a -> 'a -> int) -> 'a
val max_elt : 'a t -> compare:('a -> 'a -> int) -> 'a
val fold : 'a t -> f:('a -> 'a -> 'a) -> 'a
val fold_result : 'a t -> f:('a -> 'a -> ('a, 'e) Result.t) -> ('a, 'e) Result.t

val fold_until :
  'a t ->
  f:('a -> 'a -> ('a, 'final) Continue_or_stop.t) ->
  finish:('a -> 'final) ->
  'final

(** {0 Additional functions} *)

val append : 'a t -> 'a t -> 'a t
val compare : ('a -> 'a -> int) -> 'a t -> 'a t -> int
val concat : 'a t t -> 'a t
val cons : 'a -> 'a t -> 'a t
val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool
val filter : 'a t -> f:('a -> bool) -> 'a List.t
val filter_map : 'a t -> f:('a -> 'b option) -> 'b List.t
val fold_map : 'a t -> init:('a -> 'b) -> f:('b -> 'b -> 'b) -> 'b
val hd : 'a t -> 'a
val lift : ('a List.t -> 'b List.t) -> 'a t -> 'b t option
val lift_exn : ('a List.t -> 'b List.t) -> 'a t -> 'b t
val map : 'a t -> f:('a -> 'b) -> 'b t
val mapi : 'a t -> f:(int -> 'a -> 'b) -> 'b t
val mem : 'a t -> 'a -> equal:('a -> 'a -> bool) -> bool
val of_list : 'a List.t -> 'a t option
val of_list_exn : 'a List.t -> 'a t
val pp : ?sep:unit Fmt.t -> 'a Fmt.t -> 'a t Fmt.t
val rev : 'a t -> 'a t
val rev_append : 'a t -> 'a t -> 'a t
val rev_map : 'a t -> f:('a -> 'b) -> 'b t
val rev_mapi : 'a t -> f:('a -> int -> 'b) -> 'b t
val sort : 'a t -> compare:('a -> 'a -> int) -> 'a t
val stable_sort : 'a t -> compare:('a -> 'a -> int) -> 'a t
val tl : 'a t -> 'a List.t

module Container : Container.S1 with type 'a t := 'a t
