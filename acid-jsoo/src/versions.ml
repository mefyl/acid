module V0_13_0 = struct
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

module V0_13_1 = V0_13_0
module V0_13_2 = V0_13_1
module V0_13_3 = V0_13_2
module V0_13_4 = V0_13_3
