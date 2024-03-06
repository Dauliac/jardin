{ inputs
, config
, perSystem
, ...
}: {
  perSystem =
    { system
    , pkgs
    , self'
    , ...
    }:
    let
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
    in
    {
      packages.testInfraNixOs = pkgs.nixosTest {
        name = "test-infra-nixos";
        nodes =
          builtins.mapAttrs
            (nodeName: node:
              (testCfg.mkNodeConfig { inherit nodeName node; })
              // {
                virtualisation.graphics = false;
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
            domainNodes;
        testScript = ''
          ${nodeName}.succeed("hostname | grep -q '${nodeName}'")
        '';
      };
    };
}
