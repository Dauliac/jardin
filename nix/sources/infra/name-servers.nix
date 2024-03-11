# SPDX-License-Identifier: AGPL-3.0-or-later
{
  lib,
  config,
  ...
}: let
  inherit (lib) types mkIf mdDoc;
  cloudflare = ["1.1.1.1" "1.0.0.1"];
  google = "8.8.8.8";
  quad9 = ["9.9.9.9"];
  cfg = config.infra.nameServers;
  inherit (config.domain.cluster.networks) dns;
in {
  options = {
    infra.nameServers = {
      privacyFriendly = lib.mkOption {
        type = types.listOf types.singleLineStr;
        default = quad9 ++ cloudflare;
        description = mdDoc "Use privacy friendly DNS servers";
      };
      nonPrivacyFriendly = lib.mkOption {
        type = types.listOf types.singleLineStr;
        default = privacy ++ [google];
        description = mdDoc "Use non-privacy friendly DNS servers";
      };
      list = lib.mkOption {
        type = types.listOf types.singleLineStr;
        description = mdDoc "Use custom DNS servers";
        default = cfg.privacyFriendly;
      };
    };
  };
  config = {
    infra.nameServers = {
      list =
        mkIf (dns.nameServerKind != privacyFriendly) cfg.list
        cfg.nonPrivacyFriendly;
    };
  };
}
