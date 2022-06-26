include Base.Monad

module type BasicNestable2 = sig
  include Basic2

  module Nest (M : S) : sig
    val bind : ('a, 'e) t M.t -> f:('a -> ('b, 'e) t M.t) -> ('b, 'e) t M.t
  end
end

module type BasicNestable = sig
  include Basic

  module Nest (M : S) : sig
    val bind : 'a t M.t -> f:('a -> 'b t M.t) -> 'b t M.t
  end
end

module MakeNestable2 (M : BasicNestable2) = struct
  include Make2 (M)

  module Nest (N : S) = struct
    type ('a, 'b) t = ('a, 'b) M.t N.t

    module M = struct
      type nonrec ('a, 'b) t = ('a, 'b) t

      let return v = N.return @@ return v

      let bind v ~f =
        let module Nested = M.Nest (N) in
        Nested.bind v ~f

      let map = `Define_using_bind
    end

    include Make2 (M)
  end
end

module MakeNestable (M : BasicNestable) = struct
  type nonrec 'a t = 'a M.t

  include MakeNestable2 (struct
    include M

    type nonrec ('a, 'b) t = 'a t
  end)
end
