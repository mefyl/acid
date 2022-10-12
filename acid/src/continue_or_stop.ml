include Base.Continue_or_stop

include Monad.Make2 (struct
  type nonrec ('a, 'b) t = ('a, 'b) t

  let return v = Continue v
  let bind v ~f = match v with Continue v -> f v | Stop v -> Stop v
  let map = `Define_using_bind
end)

let ( let= ) v f = match v with Stop v -> v | Continue v -> f v
