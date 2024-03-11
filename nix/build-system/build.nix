# SPDX-License-Identifier: AGPL-3.0-or-later
{inputs, ...}: {
  perSystem = {
    system,
    inputs',
    ...
  }: let
    compile = import ./compile.nix {inherit inputs system;};
    inherit (compile) artifact;
  in {
    packages.default = artifact;
    packages.jardin = artifact;
  };
}
