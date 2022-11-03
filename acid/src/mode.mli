include module type of Mode_intf

module R :
  S with type 'a t = 'a and type ('r, _) Switch.t = 'r and type 'a js = 'a

module W :
  S
    with type 'a t = 'a option
     and type (_, 'w) Switch.t = 'w
     and type 'a js = 'a Js_of_ocaml.Js.Opt.t
