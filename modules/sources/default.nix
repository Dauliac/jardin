{ config, lib, pkgs, inputs, ... }: {
  perSystem = { system, pkgs, self', ... }: {
    lib = {
      # TODO: rewrite it as nixOsModule
      inherit ((import ./application {
        inherit lib pkgs inputs system;
      }).services.operations)
        deploy;
    };
  };
}
