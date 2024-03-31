{ inputs
, lib
, ...
}:
let
  inherit (lib) mkOption mdDoc;
  inherit (inputs.flake-parts.lib) mkPerSystemOption;
in
{
  options = {
    options.perSystem =
      mkPerSystemOption
        ({ config
         , pkgs
         , ...
         }: {
          infra.nixOs = {
            common = mkOption {
              # TODO: check if this is still needed
              # type = types.attrsOf types.attrs;
              description = mdDoc "Basic and constant nixOS configuration for the cluster nodes";
              default = {
                nix.settings = {
                  experimental-features = [ "nix-command" "flakes" ];
                  auto-optimise-store = true;
                };
                # TODO: change it into perSystem option
                # boot = { kernelPackages = pkgs.linuxPackages_hardened; };
                virtualisation = {
                  podman = {
                    enable = true;
                    defaultNetwork.settings.dns_enabled = true;
                  };
                  oci-containers.backend = "podman";
                  libvirtd.enable = true;
                };
                # required by libvirtd
                security.polkit.enable = true;
                services.openssh.enable = true;
                networking.useDHCP = true;
                networking.firewall.enable = true;
              };
            };
          };
        });
  };
}
