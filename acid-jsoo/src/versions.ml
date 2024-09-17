module V0_12_0 = struct
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

module V0_12_1 = V0_12_0
