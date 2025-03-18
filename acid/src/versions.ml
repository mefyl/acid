module V0_12_0 = struct
  (** @closed *)
  include Base

  module Array = Root.Array
  module Circular = Circular
  module Continue_or_stop = Root.Continue_or_stop
  module Either = Root.Either
  module Fmt = Acid_fmt
  module Hlist = Hlist
  module Hook = Hook
  module IQueue = Root.Queue
  module Int = Root.Int
  module Let = Root.Let
  module List = Root.List
  module List_nonempty = List_nonempty
  module Map = Root.Map
  module Mode = Mode
  module Monad = Root.Monad
  module Multi_index = Multi_index
  module Option = Root.Option
  module Pair = Pair
  module Queue = Root.Queue
  module Result = Root.Result
  module Sequence = Root.Sequence
  module Set = Root.Set
  module Split = Split
  module String = Root.String

  let logs_src = Acid_logs.src

  (** @inline *)
  include Select_jsoo.Js
end

module V0_12_1 = struct
  include V0_12_0
  module Bench = Bench
  module State_effect = State_effect
end
