type 'a t

val empty : 'a t
val length : 'a t -> int
val enqueue : 'a t -> 'a -> 'a t
val dequeue : 'a t -> 'a option * 'a t
val peek : 'a t -> 'a option
val fold : 'a t -> init:'b -> f:('b -> 'a -> 'b) -> 'b
val map : 'a t -> f:('a -> 'b) -> 'b t
val find_update : 'a t -> f:('a -> 'a option) -> 'a t * 'a option
val rfind_update : 'a t -> f:('a -> 'a option) -> 'a t * 'a option
val of_list : 'a list -> 'a t
val to_list : 'a t -> 'a list
val equal : ('a -> 'a -> bool) -> 'a t -> 'a t -> bool
