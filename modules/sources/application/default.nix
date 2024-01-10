{ lib, pkgs, inputs, system }: {
  services = import ./services { inherit lib pkgs inputs system; };
}
