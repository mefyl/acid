(lang dune 2.5)

(name acid)

(generate_opam_files true)

(license GPLv3)

(maintainers "mefyl <mefyl@gruntech.org>")

(authors "mefyl <mefyl@gruntech.org>")

(source
 (github mefyl/aci))

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
    :dev))))
