module Lwt_ = struct
  (** @canonical Acid_lwt.Bench *)
  module Bench = Bench

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

module V0_13_0 = struct
  include Acid.Versions.V0_13_0
  include Lwt_
end

module V0_13_1 = struct
  include Acid.Versions.V0_13_1
  include Lwt_
end

module V0_13_2 = V0_13_1
module V0_13_3 = V0_13_2
module V0_13_4 = V0_13_3
