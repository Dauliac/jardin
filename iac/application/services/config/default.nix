{ pkgs }:
let
  adapter =
    import ../../../infrastructure/adapters/left/configs/default.nix pkgs;
  configPath = "jardin.toml";
in
{
  write = cluster:
    adapter.write (adapter.toFile { inherit configPath cluster; });
}
