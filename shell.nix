let
  logisticPath =
    if builtins.pathExists ./path-to-logistic.nix
    then (import ./path-to-logistic.nix) else ./.logistic;
in

import "${logisticPath}/nix/shell.nix" {
  ocamlVersion = "5_3";
}
