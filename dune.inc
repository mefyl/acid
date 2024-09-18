(alias (name extdeps) (deps opam/acid.opam.extdeps))
(subdir opam
 (rule (target acid.%{version:acid}.opam) (deps (:opam ../acid.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/acid#%{version:acid}\" }")))))
 (rule (deps (universe)) (target acid.opam.locked)
  (action (run %{bin:opam} lock acid)))
 (rule (mode (promote (until-clean))) (target acid.opam.extdeps)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:acid.opam.locked} --local
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy))))
 (rule (target acid-ios.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-ios --input
     %{dep:../acid.opam} --cross
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy,base,fmt,lwt
     --cross-both ppx_here --cross-exclude schematic-jsoo))))
 (rule (target acid-ios.%{version:acid}.opam) (deps (:opam acid-ios.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/acid#%{version:acid}\" }")))))
 (rule (deps (universe)) (target acid-ios.opam.locked)
  (action (run %{bin:opam} lock acid-ios)))
 (rule (mode (promote (until-clean))) (target acid.opam.extdeps-ios)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:acid-ios.opam.locked} --local
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy
     --toolchain ios))))
 (rule (target acid-macos.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-macos --input
     %{dep:../acid.opam} --cross
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy,base,fmt,lwt
     --cross-both ppx_here --cross-exclude schematic-jsoo))))
 (rule (target acid-macos.%{version:acid}.opam)
  (deps (:opam acid-macos.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/acid#%{version:acid}\" }")))))
 (rule (deps (universe)) (target acid-macos.opam.locked)
  (action (run %{bin:opam} lock acid-macos)))
 (rule (mode (promote (until-clean))) (target acid.opam.extdeps-macos)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:acid-macos.opam.locked} --local
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy
     --toolchain macos))))
 (rule (target acid-windows.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-windows --input
     %{dep:../acid.opam} --cross
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy,base,fmt,lwt
     --cross-both ppx_here --cross-exclude schematic-jsoo))))
 (rule (target acid-windows.%{version:acid}.opam)
  (deps (:opam acid-windows.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/acid#%{version:acid}\" }")))))
 (rule (deps (universe)) (target acid-windows.opam.locked)
  (action (run %{bin:opam} lock acid-windows)))
 (rule (mode (promote (until-clean))) (target acid.opam.extdeps-windows)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:acid-windows.opam.locked} --local
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy
     --toolchain windows)))))
(alias (name extdeps) (deps opam/acid-jsoo.opam.extdeps))
(subdir opam
 (rule (target acid-jsoo.%{version:acid-jsoo}.opam)
  (deps (:opam ../acid-jsoo.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/acid#%{version:acid-jsoo}\" }")))))
 (rule (deps (universe)) (target acid-jsoo.opam.locked)
  (action (run %{bin:opam} lock acid-jsoo)))
 (rule (mode (promote (until-clean))) (target acid-jsoo.opam.extdeps)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:acid-jsoo.opam.locked} --local
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy))))
 (rule (target acid-jsoo-ios.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-ios --input
     %{dep:../acid-jsoo.opam} --cross
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy,base,fmt,lwt
     --cross-both ppx_here --cross-exclude schematic-jsoo))))
 (rule (target acid-jsoo-ios.%{version:acid-jsoo}.opam)
  (deps (:opam acid-jsoo-ios.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/acid#%{version:acid-jsoo}\" }")))))
 (rule (deps (universe)) (target acid-jsoo-ios.opam.locked)
  (action (run %{bin:opam} lock acid-jsoo-ios)))
 (rule (mode (promote (until-clean))) (target acid-jsoo.opam.extdeps-ios)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:acid-jsoo-ios.opam.locked} --local
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy
     --toolchain ios))))
 (rule (target acid-jsoo-macos.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-macos --input
     %{dep:../acid-jsoo.opam} --cross
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy,base,fmt,lwt
     --cross-both ppx_here --cross-exclude schematic-jsoo))))
 (rule (target acid-jsoo-macos.%{version:acid-jsoo}.opam)
  (deps (:opam acid-jsoo-macos.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/acid#%{version:acid-jsoo}\" }")))))
 (rule (deps (universe)) (target acid-jsoo-macos.opam.locked)
  (action (run %{bin:opam} lock acid-jsoo-macos)))
 (rule (mode (promote (until-clean))) (target acid-jsoo.opam.extdeps-macos)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:acid-jsoo-macos.opam.locked} --local
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy
     --toolchain macos))))
 (rule (target acid-jsoo-windows.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-windows --input
     %{dep:../acid-jsoo.opam} --cross
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy,base,fmt,lwt
     --cross-both ppx_here --cross-exclude schematic-jsoo))))
 (rule (target acid-jsoo-windows.%{version:acid-jsoo}.opam)
  (deps (:opam acid-jsoo-windows.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/acid#%{version:acid-jsoo}\" }")))))
 (rule (deps (universe)) (target acid-jsoo-windows.opam.locked)
  (action (run %{bin:opam} lock acid-jsoo-windows)))
 (rule (mode (promote (until-clean))) (target acid-jsoo.opam.extdeps-windows)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:acid-jsoo-windows.opam.locked} --local
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy
     --toolchain windows)))))
(alias (name extdeps) (deps opam/acid-lwt.opam.extdeps))
(subdir opam
 (rule (target acid-lwt.%{version:acid-lwt}.opam)
  (deps (:opam ../acid-lwt.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/acid#%{version:acid-lwt}\" }")))))
 (rule (deps (universe)) (target acid-lwt.opam.locked)
  (action (run %{bin:opam} lock acid-lwt)))
 (rule (mode (promote (until-clean))) (target acid-lwt.opam.extdeps)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:acid-lwt.opam.locked} --local
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy))))
 (rule (target acid-lwt-ios.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-ios --input
     %{dep:../acid-lwt.opam} --cross
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy,base,fmt,lwt
     --cross-both ppx_here --cross-exclude schematic-jsoo))))
 (rule (target acid-lwt-ios.%{version:acid-lwt}.opam)
  (deps (:opam acid-lwt-ios.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/acid#%{version:acid-lwt}\" }")))))
 (rule (deps (universe)) (target acid-lwt-ios.opam.locked)
  (action (run %{bin:opam} lock acid-lwt-ios)))
 (rule (mode (promote (until-clean))) (target acid-lwt.opam.extdeps-ios)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:acid-lwt-ios.opam.locked} --local
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy
     --toolchain ios))))
 (rule (target acid-lwt-macos.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-macos --input
     %{dep:../acid-lwt.opam} --cross
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy,base,fmt,lwt
     --cross-both ppx_here --cross-exclude schematic-jsoo))))
 (rule (target acid-lwt-macos.%{version:acid-lwt}.opam)
  (deps (:opam acid-lwt-macos.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/acid#%{version:acid-lwt}\" }")))))
 (rule (deps (universe)) (target acid-lwt-macos.opam.locked)
  (action (run %{bin:opam} lock acid-lwt-macos)))
 (rule (mode (promote (until-clean))) (target acid-lwt.opam.extdeps-macos)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:acid-lwt-macos.opam.locked} --local
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy
     --toolchain macos))))
 (rule (target acid-lwt-windows.opam) (mode (promote (until-clean)))
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite-windows --input
     %{dep:../acid-lwt.opam} --cross
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy,base,fmt,lwt
     --cross-both ppx_here --cross-exclude schematic-jsoo))))
 (rule (target acid-lwt-windows.%{version:acid-lwt}.opam)
  (deps (:opam acid-lwt-windows.opam))
  (action
   (with-stdout-to %{target}
    (progn (cat %{opam})
     (echo
      "url { src: \"git://git@gitlab.routine.co:routine/acid#%{version:acid-lwt}\" }")))))
 (rule (deps (universe)) (target acid-lwt-windows.opam.locked)
  (action (run %{bin:opam} lock acid-lwt-windows)))
 (rule (mode (promote (until-clean))) (target acid-lwt.opam.extdeps-windows)
  (action
   (with-stdout-to %{target}
    (run %{dep:../.logistic/dune/extdeps/extdeps.exe} rewrite --input
     %{dep:acid-lwt-windows.opam.locked} --local
     acid,acid-jsoo,acid-lwt,hlist,metaversion,schematic,schematic-jsoo,timmy
     --toolchain windows)))))
