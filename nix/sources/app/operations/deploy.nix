# SPDX-License-Identifier: AGPL-3.0-or-later
_: {
  # options = {
  #   jardin.app.operations.deploy = {
  #     dns = {
  #       iacService = mkOption {
  #         type = types.attrsOf types.any;
  #         description = mdDoc "The dns iac service to use";
  #         default = jardin.infra.octodns;
  #       };
  #     };
  #   };
  # };
  config = {
    infra = {
      disko.enable = true;
      octodns.enable = true;
    };
    flake = {
      jardin = {
        infra = {
          octodns = {
            enable = true;
            # TODO:  use domain to fill this
            records = [ "node1.nofreedisk.space" "node2.nofreedisk.space" ];
            provider = "cloudflare";
          };
        };
      };
    };
  };
}
