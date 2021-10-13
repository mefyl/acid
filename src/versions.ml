(** Backward compatibility versions *)

module V0_5_1 = struct
  (** @closed *)
  include Base

  module Array = Root.Array
  module Hlist = Hlist
  module IQueue = Root.Queue
  module Let = Let
  module Lwt = Root.Lwt
  module Lwt_result = Root.Lwt_result
  module Mode = Mode
  module Result = Root.Result
  module Sequence = Root.Sequence
  module Split = Split
end

module V0_5_0 = V0_5_1
