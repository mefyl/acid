module Js = Js_of_ocaml.Js

let lodash = lazy (Js.Unsafe.pure_js_expr "require('lodash')")

let escape str =
  Js.Unsafe.(
    fun_call (get (Lazy.force lodash) "escape") [| Js.Unsafe.coerce str |])
