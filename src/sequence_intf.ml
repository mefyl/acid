module Step = struct
  type ('a, 's) t =
    | Done
    | Skip of 's
    | Yield of 'a * 's
    | Yields of 'a list * 's
end
