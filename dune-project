(lang dune 3.0)

(name acid)

(generate_opam_files true)

(license LGPL-3.0-or-later)

(maintainers "mefyl <mefyl@gruntech.org>")

(authors "mefyl <mefyl@gruntech.org>")

(version 0.11.4)

(homepage https://gitlab.routine.co/routine/acid)

(bug_reports https://gitlab.routine.co/routine/acid/-/issues)

(source
 (uri git+https://gitlab.routine.co/routine/acid.git))

(package
 (name acid)
 (synopsis "Base library")
 (depends
  (alcotest
   (and
    (>= 1.1.0)
    :with-test))
  (alcotest-lwt
   (and
    (>= 1.1.0)
    :with-test))
  (base
   (>= v0.15.0))
  (crowbar :with-test)
  fmt
  (hlist
   (and
    (>= 0.2.0)
    (< 0.3.0)))
  (lwt
   (>= 5.0.0))
  (ppx_deriving :with-test)
  ppx_here
  (ppx_yojson
   (and
    (>= 1.2.0)
    :with-test))
  (schematic
   (and
    (and
     (>= 0.17.0)
     (< 0.18.0))
    :with-test))
  (schematic-jsoo
   (and
    (and
     (>= 0.17.0)
     (< 0.18.0))
    :with-test))
  (timmy
   (and
    (>= 0.16.0)
    (< 0.17.0))))
 (depopts
  (schematic
   (and
    (>= 0.17.0)
    (< 0.18.0)))
  (schematic-jsoo
   (and
    (>= 0.17.0)
    (< 0.18.0)))))

(package
 (name acid-jsoo)
 (synopsis "Base javascript library")
 (depends
  (acid
   (= :version))
  (alcotest
   (and
    (>= 1.1.0)
    :with-test))
  (conf-npm :with-test)
  js_of_ocaml
  js_of_ocaml-ppx
  (js_of_ocaml-lwt :with-test)))
