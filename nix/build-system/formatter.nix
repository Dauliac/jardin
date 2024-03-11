{inputs, ...}: {
  perSystem = {
    system,
    inputs',
    pkgs,
    ...
  }: let
    formatterPackages = import ./formatter-dependencies.nix {inherit pkgs;};
  in {
    formatter = pkgs.writeShellApplication {
      name = "normalise_nix";
      runtimeInputs = formatterPackages;
      text = ''
        set -o xtrace
        ${pkgs.alejandra}/bin/alejandra "$@"
        ${pkgs.statix}/bin/statix fix "$@"
      '';
    };
  };
}
