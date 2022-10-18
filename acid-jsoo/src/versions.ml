module V0_9_1 = struct
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

module V0_9_0 = V0_9_1
