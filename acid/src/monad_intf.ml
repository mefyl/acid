include Base.Monad

module type BASIC_NESTABLE2 = sig
  include Basic2

  module Nest2 (M : S2) : sig
    val bind :
      (('a, 'c) t, 'c) M.t ->
      f:('a -> (('b, 'c) t, 'c) M.t) ->
      (('b, 'c) t, 'c) M.t
  end
end

module type BASIC_NESTABLE = sig
  include Basic

  module Nest2 (M : S2) : sig
    val bind : ('a t, 'c) M.t -> f:('a -> ('b t, 'c) M.t) -> ('b t, 'c) M.t
  end
end

module type NESTABLE = sig
  include S

  module Nest (Nested : S) : sig
    include S with type 'a t = 'a t Nested.t
  end

  module Nest2 (Nested : S2) : sig
    include S2 with type ('a, 'b) t = ('a t, 'b) Nested.t
  end
end

module type NESTABLE2 = sig
  include Base.Monad.S2

  module Nest
      (Outer : S) : sig
    type ('a, 'b) nested

    include S2 with type ('a, 'b) t = ('a, 'b) nested Outer.t
  end
  with type ('a, 'b) nested := ('a, 'b) t

  module Nest2
      (Outer : S2) : sig
    type ('a, 'b) nested

    include S2 with type ('a, 'b) t = (('a, 'b) nested, 'b) Outer.t
  end
  with type ('a, 'b) nested := ('a, 'b) t
end

module S_to_S2 (X : S) : S2 with type ('a, 'e) t = 'a X.t = struct
  include X

  type ('a, 'e) t = 'a X.t
end

module S2_to_S3 (X : S2) : S3 with type ('a, 'd, 'e) t = ('a, 'd) X.t = struct
  include X

  type ('a, 'd, 'e) t = ('a, 'd) X.t
end

module Ident2 = S_to_S2 (Ident)
module Ident3 = S2_to_S3 (Ident2)
