{
  moduleWithSystem,
  inputs,
  ...
}: let
  inherit (inputs) nix-snapshotter;
  inherit (inputs) disko;
in {
  config.flake.nixosModules.jardin = moduleWithSystem (
    perSystem @ {
      config,
      inputs,
      pkgs,
      system,
    }: nixOs @ {
      lib,
      pkgs,
      system,
      ...
    }: {
      _module.args = {
        jardinLib = (import ./lib.nix) nixOs;
      };
      # nixpkgs.overlays = [nix-snapshotter.overlays.default];
      imports = [
        nix-snapshotter.nixosModules.default
        # disko.nixosModules.disko
        ./commons.nix
        ./options.nix
        ./users.nix
        # ./disko.nix
        ./k3s.nix
        ./nix-snapshotter.nix
        ./auditd.nix
        ./sshd.nix
      ];
    }
  );
}
