let
  logisticPath =
    if builtins.pathExists ./path-to-logistic.nix
    then (import ./path-to-logistic.nix) else ./.logistic;

  logisticFullNixShell = import "${logisticPath}/nix/full-nix-shell.nix";

  thisRoutineRepo = logisticFullNixShell.lib.mkRoutineRepo ./. {
    ocamlVersion = "5.1.1";
  };
in
thisRoutineRepo.devShells.${builtins.currentSystem}.default
