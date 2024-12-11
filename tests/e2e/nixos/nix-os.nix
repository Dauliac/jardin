{
  config,
  inputs,
  ...
}: let
  nodeName = "test";
  inherit (config) flake;
  inherit (config.test) spy;
in {
  perSystem = perSystem @ {
    config,
    pkgs,
    lib',
    ...
  }: let
    cfg = config.packages;
  in {
    packages = {
      testInfraNixOs = pkgs.testers.runNixOSTest {
        name = "test";
        nodes.${nodeName} = {
          config,
          pkgs,
          ...
        }: {
          imports = [
            flake.nixosModules.test
          ];
        };
        interactive.nodes.${nodeName} = {
          config,
          pkgs,
          ...
        }: {
          virtualisation = {
            diskSize = 1024 * 1024;
            forwardPorts = [
              {
                from = "host";
                host.port = spy.sshHostPort;
                guest.port = 22;
              }
            ];
          };
        };
        testScript = ''
          ${nodeName}.succeed("ls")
          ${nodeName}.succeed("${pkgs.disko}/bin/disko-install --disk dev-vda /dev/vda --flake ${../../..}#${nodeName}")
          ${nodeName}.shutdown()
          ${nodeName}.start()
          ${nodeName}.succeed("${pkgs.k3s}/bin/k3s kubectl run -it jardin-nixos-test-pod --image=busybox --restart=Never -- pwd")
        '';
      };
      devInfraNixOs = perSystem.config.test.spy.mkDevScript cfg.testInfraNixOs.driverInteractive;
    };
  };
}
