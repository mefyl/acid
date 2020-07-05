include Array

module Monadic2 (Monad : Base.Monad.S2) = struct
  include Base.Array

  let iter ~f a =
    let open Monad in
    fold ~init:(Monad.return ()) ~f:(fun acc e -> acc >>= fun () -> f e) a
end

module Monadic (Monad : Base.Monad.S) = struct
  include Monadic2 (struct
    include Monad

    type nonrec ('a, 'b) t = 'a t
  end)
end
