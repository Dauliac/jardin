{ inputs, ... }: {
  perSystem =
    { system
    , inputs'
    , pkgs
    , ...
    }:
    let
      compile = import ./compile.nix { inherit inputs system; };
      inherit (compile) artifact;
      formatterPackages = import ./formatter-dependencies.nix { inherit pkgs; };
    in
    {
      formatter = pkgs.writeShellApplication {
        name = "normalise_nix";
        runtimeInputs = formatterPackages;
        text = ''
          set -o xtrace
          alejandra "$@"
          nixpkgs-fmt "$@"
          statix fix "$@"
        '';
      };
    };
}
