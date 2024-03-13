# SPDX-License-Identifier: AGPL-3.0-or-later
{ ... }: {
  imports = [ ./nix-os.nix ];
  options = {
    # TODO: write helper and mock tool to write infrastructure tests
    # test.infra.lib = mkOption {
    #   default = "nixos";
    #   description = "Tools to test infrastructure layer";
    #   type = types.attrsOf (types.submodule (_: {
    #     options = {
    #       mkTest = mkOption {
    #         default = false;
    #         description = "Generate infrastructure layer tests";
    #         default = { name, pkgs, test}: {
    #           tests.nix-os = pkgs.nixosTest test;;
    #         };
    #       };
    #     };
    #   }));
    # };
  };
}
