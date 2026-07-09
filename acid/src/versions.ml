module V0_13_0 = struct
  (** @closed *)
  include Base

  module Array = Root.Array
  module Bench = Bench
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
  module Pair = Root.Pair
  module Queue = Root.Queue
  module Result = Root.Result
  module Sequence = Root.Sequence
  module Set = Root.Set
  module Split = Split
  module State_effect = State_effect
  module String = Root.String

  let logs_src = Acid_logs.src

  (** @inline *)
  include Select_jsoo.Js
end

module V0_13_1 = V0_13_0
module V0_13_2 = V0_13_1
module V0_13_3 = V0_13_2
module V0_13_4 = V0_13_3
module V0_13_5 = V0_13_4
