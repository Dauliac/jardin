# SPDX-License-Identifier: AGPL-3.0-or-later
{config, ...}: let
  testCfg = config.infra.nixOs;
  nodeName = "foo";
  domainNodes = {
    ${nodeName} = {
      ip = "localhost";
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
      inherit (config.domain.cluster.account.users) admins;
      nodes = domainNodes;
    });
in {
  config.perSystem = {pkgs, ...}: {
    packages = {
      testInfraNixOs = pkgs.nixosTest rec {
        name = "test-infra-nixos";
        inherit nodes;
        interactive.nodes =
          builtins.mapAttrs
          (nodeName: node:
            node
            // {
              services.openssh.enable = true;
              services.openssh.settings.PermitRootLogin = "yes";
              users.extraUsers.root.initialPassword = "";
              virtualisation.forwardPorts = [
                {
                  from = "host";
                  host.port = 2222;
                  guest.port = 22;
                }
              ];
            })
          nodes;
        testScript = ''
          ${nodeName}.succeed("ls")
        '';
      };
    };
  };
}
