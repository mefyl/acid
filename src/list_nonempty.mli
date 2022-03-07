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
