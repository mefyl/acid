(** Backward compatibility versions *)

module V0_6_0 = struct
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
end
