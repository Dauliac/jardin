{
  config,
  lib,
  ...
}:
let
  nodeName = "test";
  inherit (config) flake;
  inherit (config.test) spy;
  inherit (config) nixpkgsConfig;
in
{
  perSystem =
    perSystem@{
      config,
      pkgs,
      lib',
      ...
    }:
    let
      cfg = config.packages;
    in
    {
      packages = {
        testE2eOs = pkgs.testers.runNixOSTest {
          name = "test";
          nodes.${nodeName} =
            {
              config,
              pkgs,
              ...
            }:
            {
              imports = [
                flake.nixosModules.test
                {
                  nixpkgs = lib.mkForce nixpkgsConfig;
                }
              ];
            };
          interactive.nodes.${nodeName} =
            {
              config,
              pkgs,
              ...
            }:
            {
              # TODO: is it required with externalDNS installed ?
              # networking.interfaces.eth0 = {
              #   useDHCP = false;
              #   ipv4.addresses = [{
              #     address = "192.168.100.50";
              #     prefixLength = 24;
              #   }];
              # };
              virtualisation = {
                diskSize = 512 * 1024;
                memorySize = 8096;
                cores = 5;
                forwardPorts = [
                  {
                    from = "host";
                    host.port = spy.sshHostPort;
                    guest.port = 22;
                  }
                  {
                    from = "host";
                    host.port = 6443;
                    guest.port = 6443;
                  }
                ];
              };
            };
          testScript = ''
            ${nodeName}.succeed("ls")
            ${nodeName}.shutdown()
            ${nodeName}.start()
            ${nodeName}.wait_for_unit("default.target")
            ${nodeName}.succeed("su -- jardin -c 'which firefox'")
          '';
        };
        devOs = perSystem.config.test.spy.mkDevScript cfg.testE2eOs.driverInteractive;
      };
    };
}
