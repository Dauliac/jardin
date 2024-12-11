{
  inputs,
  lib,
  config,
  ...
}: let
  inherit (lib) types mkOption;
  inherit (inputs.flake-parts.lib) mkPerSystemOption;
  cfg = config.test.spy;
in {
  options = {
    test.spy = {
      sshHostPort = mkOption {
        type = types.int;
        default = 2222;
        description = "The port on which the ssh server will listen";
      };
      user = mkOption {
        type = types.str;
        default = "jardin";
        description = "The spy user for dev and tests";
      };
    };
  };
  options.perSystem =
    mkPerSystemOption
    ({
      config,
      pkgs,
      ...
    }: let
      perSystem = config.test.spy;
    in {
      options = {
        test.spy = {
          sshCommand = mkOption {
            type = types.package;
            default = pkgs.writeShellScriptBin "ssh" ''
              ${pkgs.openssh}/bin/ssh \
                -F /dev/null \
                -o UserKnownHostsFile=/dev/null \
                -o StrictHostKeyChecking=no \
                -o GlobalKnownHostsFile=/dev/null \
                -o HashKnownHosts=no \
                -o PubkeyAuthentication=yes \
                -o PasswordAuthentication=no \
                -o IdentityFile=${./nixos/id_ed25519} \
                -p ${toString cfg.sshHostPort} ${cfg.user}@localhost
            '';
            description = "The command to connect to the test or dev vm";
          };
          startScript = mkOption {
            type = types.package;
            default = pkgs.writers.writeBashBin "start.py" ''
              start_all()
              while True:
                pass
            '';
            description = "The script to start the dev mode";
          };
          mkStartCommand = mkOption {
            type = types.functionTo types.package;
            description = "The command to start the spy";
            default = driver: (
              pkgs.writers.writeBashBin "start" ''
                ${driver}/bin/nixos-test-driver --no-interactive  ${perSystem.startScript}/bin/start.py
              ''
            );
          };
          mkDevScript = mkOption {
            type = types.functionTo types.attrs;
            default = driver: (pkgs.stdenv.mkDerivation
              {
                name = "test-dev";
                src = perSystem.mkStartCommand driver;
                installPhase = ''
                  mkdir -p $out/bin
                  ln -s $src/bin/start $out/bin/start
                  ln -s ${perSystem.sshCommand}/bin/ssh $out/bin/ssh
                '';
              });
          };
        };
      };
    });
}
