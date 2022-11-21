include Monad_intf

module MakeNestable2 (M : BASIC_NESTABLE2) = struct
  include M
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

module MakeNestable (M : BASIC_NESTABLE) = struct
  include MakeNestable2 (struct
    include M

    type nonrec ('a, 'b) t = 'a t
  end)

  module Nest (N : S) = struct
    include Nest (N)

    type nonrec 'a t = ('a, unit) t
  end

  type nonrec 'a t = 'a M.t
end
