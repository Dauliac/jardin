{
  config,
  moduleWithSystem,
  withSystem,
  inputs,
  ...
}:
let
  cfg = config;
in
{
  config = {
    flake = {
      nixosModules.jardin = moduleWithSystem (
        { config }:
        nixos: {
          imports = [
            inputs.catppuccin.nixosModules.catppuccin
            inputs.comin.nixosModules.comin
            inputs.home-manager.nixosModules.default
            inputs.nixos-hardware.nixosModules.dell-xps-13-9380
            inputs.nur.modules.nixos.default
            inputs.sops-nix.nixosModules.default
            inputs.disko.nixosModules.disko
            ./configuration.nix
            {
              i18n.defaultLocale = "fr_FR.UTF-8";
              home-manager = {
                sharedModules = [
                  inputs.catppuccin.homeModules.catppuccin
                  inputs.betterfox-nix.homeManagerModules.betterfox
                  {
                    nixpkgs = cfg.nixpkgsConfig;
                  }
                ];
                extraSpecialArgs = { inherit inputs; };
                users.jardin = ../home-manager/config.nix;
              };
            }
          ];
        }
      );
      nixosModules.default = config.flake.nixOsModules.jardin;
      nixosConfigurations.jardin = withSystem "x86_64-linux" (
        _:
        inputs.nixpkgs.lib.nixosSystem {
          modules = [
            (
              {
                config,
                lib,
                packages,
                pkgs,
                ...
              }:
              {
                imports = [
                  cfg.flake.nixosModules.jardin
                  {
                    nixpkgs = cfg.nixpkgsConfig;
                  }
                  ./hardware.nix
                  {
                    networking.hostName = "jardin";
                  }
                ];
              }
            )
          ];
        }
      );
    };
  };
}
