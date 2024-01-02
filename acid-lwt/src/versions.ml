module V0_12_0 = struct
  include Acid

  (** @canonical Acid_lwt.Lwt *)
  module Lwt = struct
    include Lwt_acid
    module Rw_mutex = Lwt_rw_mutex
  end

  (** @canonical Acid_lwt.Lwt_result *)
  module Lwt_result = Lwt_result_acid
end
