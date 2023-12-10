open Base
include module type of Pair_intf

val equal :
  ('first -> 'first -> bool) ->
  ('second -> 'second -> bool) ->
  'first * 'second ->
  'first * 'second ->
  bool

val compare :
  ('first -> 'first -> int) ->
  ('second -> 'second -> int) ->
  'first * 'second ->
  'first * 'second ->
  int

val pp : 'first Fmt.t -> 'second Fmt.t -> ('first * 'second) Fmt.t

module Make (First : sig
  include Comparable.S
  include Printable.S with type t := t
end) (Second : sig
  include Comparable.S
  include Printable.S with type t := t
end) :
  S
    with type t = First.t * Second.t
     and type First.t = First.t
     and type Second.t = Second.t
