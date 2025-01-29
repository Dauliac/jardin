{ inputs, ... }:
{
  imports = [
    inputs.treefmt-nix.flakeModule
    ./docs.nix
    ./dev.nix
    ./treefmt.nix
  ];
}
