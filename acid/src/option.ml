include Base.Option

include Monad.MakeNestable (struct
  type 'a t = 'a option

  let return x = Some x
  let map t ~f = match t with None -> None | Some a -> Some (f a)
  let map = `Custom map
  let bind o ~f = match o with None -> None | Some x -> f x

  module Nest2 (M : Monad.S2) = struct
    let bind v ~f =
      M.bind v ~f:(function None -> M.return None | Some v -> f v)
  end
end)

let traverse (l : 'a list) ~f = Base.List.map l ~f |> all
