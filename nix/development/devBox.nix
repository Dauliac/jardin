{ inputs, ... }: {
  perSystem =
    { system
    , pkgs
    , self'
    , ...
    }: {
      packages.sandbox = pkgs.testers.runNixOSTest {
        name = "sandbox";
        interactive.nodes = {
          machine = { pkgs, ... }: {
            virtualisation.graphics = false;
            imports = [ inputs.disko.nixosModules.disko ];
            disko.devices = import ./disks.nix { };
            networking.firewall.allowedTCPPorts = [
              6443 # k3s: required so that pods can reach the API server (running on port 6443 by default)
            ];
            services.k3s.enable = true;
            services.k3s.role = "server";
            environment.systemPackages = [ pkgs.k3s ];
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
          };
        };
        testScript = ''
          machine.wait_for_unit("network-online.target")
          start_all()
        '';
      };
    };
}
