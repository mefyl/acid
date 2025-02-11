module V0_12_0 = struct
  include Acid.Versions.V0_12_0

  (** @canonical Acid_lwt.Lwt *)
  module Lwt = struct
    include Lwt_acid
    module Rw_mutex = Lwt_rw_mutex
  end

  (** @canonical Acid_lwt.Lwt_result *)
  module Lwt_result = Lwt_result_acid

  (** @canonical Acid_lwt.Lwt_guarded *)
  module Lwt_guarded = Lwt_guarded
end

module V0_12_1 = V0_12_0

module V0_12_2 = struct
  include V0_12_0
  module Bench = Bench
end
