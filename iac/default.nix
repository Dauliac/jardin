{ pkgs }:
let application = import ./application/default.nix { inherit pkgs; };
in { lib = config: { deploy = (application.services.deploy config); }; }
