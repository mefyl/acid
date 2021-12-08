type 'a t

val acquire : 'a t -> f:('a -> 'b Lwt.t) -> 'b Lwt.t

val make : 'a -> 'a t
