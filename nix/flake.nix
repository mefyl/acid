{
  inputs = {
    # Point to our fork until https://github.com/tweag/opam-nix/issues/99 is done
    opam-nix.url = "github:sir4ur0n/opam-nix/support-git-urls";
    opam-nix.inputs.nixpkgs.follows = "nixpkgs";
    flake-compat = {
      url = "github:edolstra/flake-compat";
      flake = false;
    };
    flake-utils.url = "github:numtide/flake-utils";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    opam-repository = {
      url = "github:ocaml/opam-repository";
      flake = false;
    };
    routine-opam-repository = {
      url = "git+ssh://git@gitlab.routine.co/routine/opam.git";
      flake = false;
    };
  };
  outputs =
    { self
    , flake-utils
    , opam-nix
    , nixpkgs
    , opam-repository
    , routine-opam-repository
    , ...
    }: {
      templates.default = {
        path = ./template;
        description = "Initialize a setup for developing on a Routine OCaml repository";
      };
      lib.mkRoutineRepo = path: { localPackages ? null
                                , extraDevPackagesQuery ? { }
                                , extraDevPackages ? (pkgs: [ ])
                                , extraOverlay ? (final: prev: { })
                                , resolveArgsOverride ? (args: args)
                                , extraRepos ? [ ]
                                ,
                                }:
        flake-utils.lib.eachDefaultSystem (
          system:
          let
            gitPath = builtins.fetchGit path;
            pkgs = nixpkgs.legacyPackages.${system};
            on = opam-nix.lib.${system};
            localPackages_ = if localPackages != null then localPackages else
            builtins.attrNames
              (builtins.mapAttrs (_: pkgs.lib.last)
                (on.listRepo (on.makeOpamRepo gitPath)));
            devPackagesQuery =
              {
                # You can add "development" packages here. They will get added to the devShell automatically.
              }
              // extraDevPackagesQuery;
            query =
              devPackagesQuery
              // {
                ## - force the ocaml compiler to be taken from opam-repository:
                ocaml-base-compiler = "*";
                angstrom = "0.15.0";

              };
            scope =
              on.buildOpamProject'
                (resolveArgsOverride {
                  repos = [ opam-repository routine-opam-repository ] ++ extraRepos;
                  resolveArgs.with-test = true;
                  resolveArgs.criteria = "-removed,-count[avoid-version:,true],-count[version-lag:,true],-changed,-count[version-lag:,false],-count[missing-depexts:,true],-new";
                })
                gitPath
                query;
            overlay = final: prev: {
              # You can add overrides here
              # To add a local, development repo (e.g. your hacked `schematic` rather than the one from Routine's `opam` repo), you can `overrideAttrs` to replace the source like this:
              #
              # schematic = prev.schematic.overrideAttrs (a: {
              #   buildInputs = a.buildInputs or [ ] ++ [ prev.logs ];
              #   src = builtins.fetchGit /home/sir4ur0n/code/routine/schematic;
              # });
              #
              # Remember to update your nix-shell (e.g. with `direnv reload`) after every change in the local repo.
              timmy-jsoo = prev.timmy-jsoo.overrideAttrs (a: { buildInputs = a.nativeBuildInputs or [ ] ++ [ pkgs.nodejs prev.logs ]; });
              timmy-unix = prev.timmy-unix.overrideAttrs (a: { buildInputs = a.buildInputs or [ ] ++ [ pkgs.tzdata prev.logs ]; });
              timmy-lwt = prev.timmy-lwt.overrideAttrs (a: { buildInputs = a.buildInputs or [ ] ++ [ prev.logs ]; });
              schematic = prev.schematic.overrideAttrs (a: { buildInputs = a.buildInputs or [ ] ++ [ prev.logs ]; });
              routine-controller-lib = prev.routine-controller-lib.overrideAttrs (a: { buildInputs = a.buildInputs or [ ] ++ [ pkgs.nodejs pkgs.yarn ]; });
              routine-front-controller = prev.routine-front-controller.overrideAttrs (a: { buildInputs = a.buildInputs or [ ] ++ [ pkgs.nodejs pkgs.yarn ]; });
              conf-tzdata = null;
            };
            scope' = scope.overrideScope overlay;
            # Packages from devPackagesQuery
            devPackages = [
              pkgs.ocaml-ng.ocamlPackages_5_2.ocamlformat_0_26_2
              pkgs.ocaml-ng.ocamlPackages_5_2.ocaml-lsp
            ] ++
            builtins.attrValues
              (pkgs.lib.getAttrs (builtins.attrNames devPackagesQuery) scope');
            # Packages in this workspace
            packages =
              pkgs.lib.getAttrs localPackages_ scope';


            routine_run = pkgs.buildFHSEnv {
              name = "routine-run";

              targetPkgs = pkgs: [
                pkgs.xdg-utils
                pkgs.glibc.bin
                pkgs.glib
                pkgs.iana-etc
                pkgs.nss
                pkgs.libdrm
                pkgs.gtk3
                pkgs.pango
                pkgs.nspr
                pkgs.dbus
                pkgs.dbus-glib
                pkgs.cairo
                pkgs.xorg.libX11
                pkgs.xorg.libXext
                pkgs.xorg.libXfixes
                pkgs.xorg.libXrandr
                pkgs.xorg.libxcb
                pkgs.xorg.libXcomposite
              ] ++ pkgs.electron.buildInputs ++ pkgs.electron.unwrapped.buildInputs;

              runScript = pkgs.writers.writeBash "routine-run" ''
                executable="''${1:-./dist_electron/linux-unpacked/routine}"
                shift

                exec "$executable" "$@"
              '';

              TZ = "Europe/Paris";

            };

            ciPackages = import ./ci-packages.nix {
              inherit pkgs;
            };

          in
          {
            legacyPackages = scope';

            inherit packages;

            devShells.default = pkgs.mkShell {
              NODE_OPTIONS = "--max_old_space_size=4096";
              inputsFrom = builtins.attrValues packages;
              buildInputs =
                devPackages ++
                # TODO Take `pkgs` as argument for `ciPackages` without breaking Ubuntu CI
                ciPackages ++
                (extraDevPackages pkgs) ++
                [ routine_run ];
            };
          }
        );
    };
}
