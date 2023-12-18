{pkgs}: {
  toFile = cluster: builtins.toTOML cluster;
  write = {
    configPath,
    content,
  }:
    pkgs.writeText configPath content;
}
