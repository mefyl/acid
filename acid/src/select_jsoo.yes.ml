module Either = struct
  type (_, _) js = Js_of_ocaml.Js.Unsafe.any
end

module List_nonempty = struct
  type 'a js = 'a Js_of_ocaml.Js.js_array Js_of_ocaml.Js.t
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
  type 'a js = 'a Js_of_ocaml.Js.Opt.t
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
  type ('l, 'r) js = Js_of_ocaml.Js.Unsafe.any
end

module Js = struct
  module Js = struct
    include Js_of_ocaml.Js

    module Pair : sig
      type ('a, 'b) t
    end = struct
      type ('a, 'b) t = Unsafe.any js_array
    end

    module Iterator = struct
      type 'a t =
        < next :
            < done_ : bool Js_of_ocaml.Js.t readonly_prop
            ; value : 'a readonly_prop >
            Js_of_ocaml.Js.t
            meth >
    end

    module Map = struct
      type ('k, 'v) t =
        < entries :
            ('k, 'v) Pair.t Js_of_ocaml.Js.t Iterator.t Js_of_ocaml.Js.t meth
        ; get : 'k -> 'v Opt.t meth
        ; set : 'k -> 'v -> unit meth
        ; delete : 'k -> unit meth
        ; keys : 'k Iterator.t Js_of_ocaml.Js.t meth
        ; values : 'v Iterator.t Js_of_ocaml.Js.t meth >
    end
  end
end

module Map = struct
  module M (K : Base.Comparator.S) = struct
    type 'a js =
      (Js_of_ocaml.Js.js_string Js_of_ocaml.Js.t, 'a) Js.Js.Map.t
      Js_of_ocaml.Js.t
  end
end
