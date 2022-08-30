(lang dune 3.0)

(name acid)

(generate_opam_files true)

(license LGPL-3.0-or-later)

(maintainers "mefyl <mefyl@gruntech.org>")

(authors "mefyl <mefyl@gruntech.org>")

(version 0.8.3)

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
   (>= 0.13.1))
  fmt
  (lwt
   (>= 5.0.0))
  (ppx_yojson
   (and
    (>= 1.2.0)
    :with-test))
  (schematic
   (and
    (and
     (>= 0.14.0)
     (< 0.15.0))
    :with-test))
  (schematic-jsoo
   (and
    (and
     (>= 0.14.0)
     (< 0.15.0))
    :with-test)))
 (depopts
  (schematic
   (and
    (>= 0.14.0)
    (< 0.15.0)))
  (schematic-jsoo
   (and
    (>= 0.14.0)
    (< 0.15.0)))))
