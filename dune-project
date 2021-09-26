(lang dune 2.5)

(name acid)

(generate_opam_files true)

(license GPLv3)

(maintainers "mefyl <mefyl@gruntech.org>")

(authors "mefyl <mefyl@gruntech.org>")

(version 0.3.0)

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
  (lwt
   (>= 5.0.0))
  (ocamlformat
   (and
    (= 0.17.0)
    :dev))
  (schematic
   (and
    (= 0.9.0)
    :with-test))
  (schematic-jsoo
   (and
    (= 0.9.0)
    :with-test)))
 (depopts
  (schematic
   (= 0.9.0))
  (schematic-jsoo
   (= 0.9.0))))
