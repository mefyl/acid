module V0_10_3 = struct
  module Js = struct
    include Js_of_ocaml.Js
    module Array = Array
    module Iterator = Iterator
    module Lodash = Lodash
    module Map = Map
    module Pair = Pair
    module Promise = Promise
  end
end

module V0_10_2 = V0_10_3
module V0_10_1 = V0_10_2
module V0_10_0 = V0_10_1
