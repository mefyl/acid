include Base.Set

let pp pp =
  let open Fmt in
  let indent = 2 in
  using (fun map -> to_sequence map |> Base.Sequence.to_seq)
  @@ box
  @@ const string "{"
     ++ (hvbox ~indent:(indent - 1)
        @@ (cut ++ seq ~sep:comma (box ~indent @@ pp)))
     ++ cut
     ++ const string "}"

module type ELEMENT = Select_schema.Set.ELT

module M (Elt : ELEMENT) = struct
  include Select.Set.M (Elt)
  include Select_schema.Set.M (Elt)

  let pp = pp
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

module type ELEMENT_PRINTABLE = sig
  type t

  val pp : t Fmt.t

  include ELEMENT with type t := t
end

module M_printable (Element : ELEMENT_PRINTABLE) = struct
  include M (Element)

  let pp set = pp Element.pp set
end
