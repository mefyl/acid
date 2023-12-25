module V0_11_11 : sig
  include module type of Sequence_intf.V0_11_11

  module Make2 (M : Base.Monad.S2) :
    S2 with type ('a, 'b) t = ('a, 'b) Sequence.Make2(M).t and module M = M

  module Make (M : Base.Monad.S) :
    S with type 'a t = 'a Sequence.Make(M).t and module M = M
end = struct
  include Sequence
  include Sequence_intf.V0_11_11
end

module V0_11_0 : sig
  include module type of Sequence_intf.V0_11_0

  module Make2 (M : Base.Monad.S2) :
    S2 with type ('a, 'b) t = ('a, 'b) Sequence.Make2(M).t and module M = M

  module Make (M : Base.Monad.S) :
    S with type 'a t = 'a Sequence.Make(M).t and module M = M
end = struct
  include Sequence
  include Sequence_intf.V0_11_0
end
