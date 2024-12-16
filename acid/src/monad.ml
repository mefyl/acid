include Monad_intf

module Make (X : Base.Monad.Basic) = struct
  include Base.Monad.Make (X)

  let traverse l ~f = Base.List.map l ~f |> all
end

module Make2 (X : Base.Monad.Basic2) = struct
  include Base.Monad.Make2 (X)

  let traverse l ~f = Base.List.map l ~f |> all
end

module Make3 (X : Base.Monad.Basic3) = struct
  include Base.Monad.Make3 (X)

  let traverse l ~f = Base.List.map l ~f |> all
end

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

module State = struct
  module Make (State : sig
    type t
  end) =
  struct
    type 'a t = State.t -> 'a * State.t

    include Make (struct
      type nonrec 'a t = 'a t

      let return v marks = (v, marks)

      let bind v ~f marks =
        let v, marks = v marks in
        f v marks

      let map =
        let map v ~f marks =
          let v, marks = v marks in
          (f v, marks)
        in
        `Custom map
    end)
  end
end
