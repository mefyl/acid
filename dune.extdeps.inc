(rule (deps (universe)) (target acid.opam.locked)
 (action (run %{bin:opam} lock acid)))
(rule (alias extdeps) (mode (promote (until-clean)))
 (target acid.opam.extdeps)
 (action
  (with-stdout-to %{target}
   (run %{dep:.logistic/dune/extdeps/extdeps.exe} rewrite --input
    %{dep:acid.opam.locked} --exclude schematic,schematic-jsoo))))
(rule (deps (universe)) (target acid-jsoo.opam.locked)
 (action (run %{bin:opam} lock acid-jsoo)))
(rule (alias extdeps) (mode (promote (until-clean)))
 (target acid-jsoo.opam.extdeps)
 (action
  (with-stdout-to %{target}
   (run %{dep:.logistic/dune/extdeps/extdeps.exe} rewrite --input
    %{dep:acid-jsoo.opam.locked} --exclude schematic,schematic-jsoo))))
