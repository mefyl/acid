module Js = struct
  include Js_of_ocaml.Js
  module Array = Array
  module Iterator = Iterator
  module Lodash = Lodash
  module Map = Map
  module Pair = Pair
  module Promise = Promise
end
