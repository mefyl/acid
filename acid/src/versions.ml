module V0_11_0 = struct
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
  module Multi_index = Multi_index
  module Option = Root.Option
  module Queue = Root.Queue
  module Result = Root.Result
  module Sequence = Root.Sequence
  module Set = Root.Set
  module Split = Split
  module String = Root.String

  (** @inline *)
  include Select_jsoo.Js
end

module V0_11_1 = V0_11_0

module V0_11_2 = struct
  (** @inline *)
  include V0_11_1

  module Hook = Hook
end

module V0_11_3 = V0_11_2

module V0_11_4 = struct
  (** @inline *)
  include V0_11_3

  module Circular = Circular
end

module V0_11_5 = V0_11_4
module V0_11_6 = V0_11_5
module V0_11_7 = V0_11_6

module V0_11_8 = struct
  include V0_11_7

  module Lwt = struct
    include Lwt
    module Rw_mutex = Lwt_rw_mutex
  end

  let logs_src = Acid_logs.src
end

module V0_11_9 = V0_11_8
module V0_11_10 = V0_11_9
