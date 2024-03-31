{config, ...}: let
  inherit (config) domain;
in {
  config.perSystem = {
    pkgs,
    config,
    ...
  }: let
    testCfg = config.infra.nixOs;
    nodeName = "foo";
    sshHostPort = 2222;
    rootPassword = "jardin";
    domainNodes = {
      ${nodeName} = {
        ip = "10.0.2.1";
        role = "master";
        resources = {
          cpu = 1;
          memory = "1024MiB";
          storage = {
            disks = [
              {
                device = "/dev/sda";
                size = "20GB";
              }
            ];
            uefi = false;
          };
        };
      };
    };
    nodes =
      builtins.mapAttrs
      (nodeName: node: node // {virtualisation.graphics = false;})
      (testCfg.mkNixOs {
        inherit (domain.cluster.account.users) admins;
        nodes = domainNodes;
      });
    sshCommand = pkgs.writers.writeBashBin "ssh" ''
      ${pkgs.passh}/bin/passh \
        -p "${rootPassword}" \
        ${pkgs.openssh}/bin/ssh \
        -F /dev/null \
        -o UserKnownHostsFile=/dev/null \
        -o StrictHostKeyChecking=no \
        -o GlobalKnownHostsFile=/dev/null \
        -o HashKnownHosts=no \
        -o PubkeyAuthentication=no \
        -o PasswordAuthentication=yes \
        -p ${toString sshHostPort} root@localhost
    '';
    startScript = pkgs.writers.writeBashBin "start.py" ''
      start_all()
      while True:
        pass
    '';
    startCommand = {driver}:
      pkgs.writers.writeBashBin "start" ''
        ${driver}/bin/nixos-test-driver --no-interactive  ${startScript}/bin/start.py
      '';
  in {
    packages = rec {
      testInfraNixOs = pkgs.nixosTest rec {
        name = "test-infra-nixos";
        inherit nodes;
        interactive.nodes =
          builtins.mapAttrs
          (nodeName: node:
            node
            // {
              environment.systemPackages = with pkgs; [
                systemctl-tui
                htop
                k9s
              ];
              services.openssh.enable = true;
              services.openssh.settings.PermitRootLogin = "yes";
              users.users.root = {
                initialPassword = rootPassword;
                hashedPassword = null;
                hashedPasswordFile = null;
                initialHashedPassword = null;
              };
              virtualisation.forwardPorts = [
                {
                  from = "host";
                  host.port = sshHostPort;
                  guest.port = 22;
                }
              ];
            })
          nodes;
        # TODO: add test script that run kubectl run -it jardin-nixos-test-pod --image=busybox --restart=Never -- pwd
        testScript = ''
          ${nodeName}.succeed("ls")
        '';
      };
      devInfraNixOs = pkgs.stdenv.mkDerivation {
        name = "test-dev";
        # TODO: add one ssh script per node
        src = startCommand {
          driver = testInfraNixOs.driverInteractive;
        };
        installPhase = ''
          mkdir -p $out/bin
          ln -s $src/bin/start $out/bin/start
          ln -s ${sshCommand}/bin/ssh $out/bin/ssh
        '';
      };
    };
  };
}
