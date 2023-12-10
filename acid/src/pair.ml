open Base
include Pair_intf

let equal equal_first equal_second (lhs_first, lhs_second)
    (rhs_first, rhs_second) =
  equal_first lhs_first rhs_first && equal_second lhs_second rhs_second

let compare compare_first compare_second (lhs_first, lhs_second)
    (rhs_first, rhs_second) =
  match compare_first lhs_first rhs_first with
  | 0 -> compare_second lhs_second rhs_second
  | n -> n

let pp pp_first pp_second f (first, second) =
  Fmt.pf f "(@[%a,@ %a@])" pp_first first pp_second second

module Make (First : sig
  type t

  include Comparable.S with type t := t
  include Printable.S with type t := t
end) (Second : sig
  include Comparable.S
  include Printable.S with type t := t
end) =
struct
  module First = First
  module Second = Second

  type t = First.t * Second.t

  include Comparable.Make (struct
    type nonrec t = t

    let compare = compare First.compare Second.compare

    let sexp_of_t (first, second) =
      Sexp.List
        [ First.comparator.sexp_of_t first; Second.comparator.sexp_of_t second ]
  end)

  let pp = pp First.pp Second.pp
end
