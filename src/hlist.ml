type _ t =
  | ( :: ) : 'a * 'b t -> ('a -> 'b) t
  | [] : unit t
