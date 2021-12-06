open Base

type 'a t = ( :: ) : 'a * 'a list -> 'a t

val rev : 'a t -> 'a t

val append : 'a t -> 'a t -> 'a t

val concat : 'a t t -> 'a t

val fold : 'a t -> f:('a -> 'a -> 'a) -> 'a

val map : 'a t -> f:('a -> 'b) -> 'b t

val mapi : 'a t -> f:('a -> int -> 'b) -> 'b t

val rev_mapi : 'a t -> f:('a -> int -> 'b) -> 'b t

val hd : 'a t -> 'a

val tl : 'a t -> 'a List.t

val to_list : 'a t -> 'a List.t

val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool

val pp : ?sep:unit Fmt.t -> 'a Fmt.t -> 'a t Fmt.t
