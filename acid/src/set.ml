include Base.Set

module M (Elt : Base.Comparator.S) = struct
  include Base.Set
  include Base.Set.M (Elt)

  let empty = empty (module Elt)
  let singleton = singleton (module Elt)
  let union_list = union_list (module Elt)
  let of_list = of_list (module Elt)
  let of_array = of_array (module Elt)
  let of_sorted_array = of_sorted_array (module Elt)
  let of_sorted_array_unchecked = of_sorted_array_unchecked (module Elt)

  let of_increasing_iterator_unchecked =
    of_increasing_iterator_unchecked (module Elt)
end
