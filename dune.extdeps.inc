(rule (target acid.%{version:acid}.opam) (deps (:opam acid.opam))
 (action
  (with-stdout-to %{target}
   (progn (cat %{opam})
    (echo
     "url { src: \"git://git@gitlab.routine.co:routine/acid#%{version:acid}\" }")))))
(rule (deps (universe)) (target acid.opam.locked)
 (action (run %{bin:opam} lock acid)))
(rule (alias extdeps) (mode (promote (until-clean)))
 (target acid.opam.extdeps)
 (action
  (with-stdout-to %{target}
   (run %{dep:.logistic/dune/extdeps/extdeps.exe} rewrite --input
    %{dep:acid.opam.locked} --exclude
    acid,acid-jsoo,hlist,schematic,schematic-jsoo,timmy))))
(rule (target acid-jsoo.%{version:acid-jsoo}.opam)
 (deps (:opam acid-jsoo.opam))
 (action
  (with-stdout-to %{target}
   (progn (cat %{opam})
    (echo
     "url { src: \"git://git@gitlab.routine.co:routine/acid#%{version:acid-jsoo}\" }")))))
(rule (deps (universe)) (target acid-jsoo.opam.locked)
 (action (run %{bin:opam} lock acid-jsoo)))
(rule (alias extdeps) (mode (promote (until-clean)))
 (target acid-jsoo.opam.extdeps)
 (action
  (with-stdout-to %{target}
   (run %{dep:.logistic/dune/extdeps/extdeps.exe} rewrite --input
    %{dep:acid-jsoo.opam.locked} --exclude
    acid,acid-jsoo,hlist,schematic,schematic-jsoo,timmy))))
