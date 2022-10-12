include Base.Monad

module type BasicNestable2 = sig
  include Basic2

  module Nest2 (M : S2) : sig
    val bind :
      (('a, 'c) t, 'c) M.t ->
      f:('a -> (('b, 'c) t, 'c) M.t) ->
      (('b, 'c) t, 'c) M.t
  end
end

module type BasicNestable = sig
  include Basic

  module Nest2 (M : S2) : sig
    val bind : ('a t, 'c) M.t -> f:('a -> ('b t, 'c) M.t) -> ('b t, 'c) M.t
  end
end

module MakeNestable2 (M : BasicNestable2) = struct
  include Make2 (M)

  module Nest2 (N : S2) = struct
    type ('a, 'b) t = (('a, 'b) M.t, 'b) N.t

    include Make2 (struct
      type nonrec ('a, 'b) t = ('a, 'b) t

      let return v = N.return @@ return v

      let bind v ~f =
        let module Nested = M.Nest2 (struct
          include N

          type nonrec ('a, 'b) t = ('a, 'b) t
        end) in
        Nested.bind v ~f

      let map = `Define_using_bind
    end)
  end

  module Nest (N : S) = struct
    include Nest2 (struct
      include N

      type ('a, _) t = 'a N.t
    end)

    type ('a, 'b) t = ('a, 'b) M.t N.t
  end
end

module MakeNestable (M : BasicNestable) = struct
  type nonrec 'a t = 'a M.t

  include MakeNestable2 (struct
    include M

    type nonrec ('a, 'b) t = 'a t
  end)
end
