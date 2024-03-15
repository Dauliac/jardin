# SPDX-License-Identifier: AGPL-3.0-or-later
{pkgs}: let
  adapter =
    import ../../../infrastructure/adapters/left/configs/default.nix pkgs;
  configPath = "jardin.toml";
in {
  write = cluster:
    adapter.write (adapter.toFile {inherit configPath cluster;});
}
