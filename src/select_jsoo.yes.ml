module Either = struct
  type (_, _) js = Js_of_ocaml.Js.Unsafe.any
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
