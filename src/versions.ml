module V0_8_1 = struct
  (** @closed *)
  include Base

  module Array = Root.Array
  module Hlist = Hlist
  module IQueue = Root.Queue
  module Let = Let
  module Lwt = Root.Lwt
  module Lwt_result = Root.Lwt_result
  module Lwt_guarded = Lwt_guarded
  module Mode = Mode
  module Result = Root.Result
  module Sequence = Root.Sequence
  module Split = Split
  module List_nonempty = List_nonempty
  module Either = Root.Either
  module Option = Root.Option
end

module V0_8_0 = V0_8_1

module V0_8_2 = struct
  (** @inline *)
  include V0_8_1

  module Fmt = Acid_fmt
end

module V0_8_3 = struct
  (** @inline *)
  include V0_8_2

  module List = Root.List
  module Map = Root.Map

  module Result = struct
    include Result

    let failf = Base.Result.failf
  end
end

module V0_8_4 = struct
  (** @inline *)
  include V0_8_3

  module Int = Root.Int
  module Result = Root.Result
  module String = Root.String

  module Let = struct
    include Let

    module Syntax2 (Monad : Base.Monad.S2) = struct
      include Syntax2 (Monad)

      let ( let*? ) = ( let*?? )
      and ( let+? ) = ( let+?? )
      and ( let*?? ) = ( let*? )
      and ( let+?? ) = ( let+? )
    end
  end
end

module V0_8_5 = struct
  (** @inline *)
  include V0_8_4

  module Continue_or_stop = Root.Continue_or_stop
end
