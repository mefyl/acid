type 'a t

val make : int -> 'a t
val push : 'a -> 'a t -> unit
val to_list : 'a t -> 'a list
