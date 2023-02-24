include Base.Set

module M (Elt : Select_schema.Set.ELT) = struct
  include Select.Set.M (Elt)
  include Select_schema.Set.M (Elt)

  let empty = empty (module Elt)
  let singleton v = singleton (module Elt) v
  let union_list l = union_list (module Elt) l
  let of_list l = of_list (module Elt) l
  let of_array a = of_array (module Elt) a
  let of_sequence s = of_sequence (module Elt) s
  let of_sorted_array a = of_sorted_array (module Elt) a
  let of_sorted_array_unchecked a = of_sorted_array_unchecked (module Elt) a

  let of_increasing_iterator_unchecked ~len ~f =
    of_increasing_iterator_unchecked (module Elt) ~len ~f
end
