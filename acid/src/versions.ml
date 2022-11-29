module V0_9_2 = struct
  (** @closed *)
  include Base

  module Array = Root.Array
  module Continue_or_stop = Root.Continue_or_stop
  module Either = Root.Either
  module Fmt = Acid_fmt
  module Hlist = Hlist
  module IQueue = Root.Queue
  module Int = Root.Int
  module Let = Let
  module List = Root.List
  module List_nonempty = List_nonempty
  module Lwt = Root.Lwt
  module Lwt_guarded = Lwt_guarded
  module Lwt_result = Root.Lwt_result
  module Map = Root.Map
  module Mode = Mode
  module Monad = Root.Monad
  module Option = Root.Option
  module Result = Root.Result
  module Sequence = Root.Sequence
  module Split = Split
  module String = Root.String

  (** @inline *)
  include Select_jsoo.Js
end

module V0_9_3 = struct
  include V0_9_2
  module Multi_index = Multi_index
end

module V0_9_1 = V0_9_2
module V0_9_0 = V0_9_1
