module Js = Js_of_ocaml.Js

module Either = struct
  type (_, _) js = Js.Unsafe.any
end

module List_nonempty = struct
  type 'a js = 'a Js.js_array Js.t
end

module type MODE = sig
  type 'a t
  type 'a js
end

module type SWITCH = sig
  type ('r, 'w) t
  type ('r, 'w) js
end

module R = struct
  type 'a js = 'a
end

module W = struct
  type 'a js = 'a Js.Opt.t
end

module Switch_r = struct
  type ('r, _) js = 'r
end

module Switch_w = struct
  type (_, 'w) js = 'w
end

module type SPLIT = sig
  type ('l, 'r) t
  type ('l, 'r) js
end

module Split = struct
  type ('l, 'r) js = Js.Unsafe.any
end

module Js_pair : sig
  type ('a, 'b) t
end = struct
  type ('a, 'b) t = Js.Unsafe.any Js.js_array
end

module Js_iterator = struct
  type 'a t =
    < next :
        < done_ : bool Js.t Js.readonly_prop ; value : 'a Js.readonly_prop >
        Js.t
        Js.meth >
end

module Js_map = struct
  type ('k, 'v) t =
    < entries : ('k, 'v) Js_pair.t Js.t Js_iterator.t Js.t Js.meth
    ; get : 'k -> 'v Js.Opt.t Js.meth
    ; set : 'k -> 'v -> unit Js.meth
    ; delete : 'k -> unit Js.meth
    ; values : 'v Js_iterator.t Js.t Js.meth >
end

module Map = struct
  module M (K : Base.Comparator.S) = struct
    type 'a js = (Js.js_string Js.t, 'a) Js_map.t Js.t
  end
end
