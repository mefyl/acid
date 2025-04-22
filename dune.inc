(dirs :standard .logistic)

(env
 (dev
  (flags
   (:standard -warn-error -A -warn-error +partial-match)))
 (release
  (flags
   (:standard -warn-error +A -w +unused-constructor))))

(rule
 (target dune.inc)
 (action
  (with-stdout-to
   %{target}
   (run
    %{dep:.logistic/dune/extdeps/extdeps.exe}
    generate
    --cross-both
    %{read-strings:cross-both.dune}
    --cross-exclude
    %{read-strings:cross-exclude.dune})))
 (deps dune-project .logistic/dune.inc))

(subdir
 opam
 (dynamic_include ../dune.inc))
