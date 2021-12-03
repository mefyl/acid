open Base

type 'a t = ( :: ) : 'a * 'a list -> 'a t

val map : 'a t -> f:('a -> 'b) -> 'b t

val hd : 'a t -> 'a

val tl : 'a t -> 'a List.t

val to_list : 'a t -> 'a List.t

val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool

val pp : ?sep:unit Fmt.t -> 'a Fmt.t -> 'a t Fmt.t
