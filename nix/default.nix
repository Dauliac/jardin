{
  flake-parts-lib,
  config,
  pkgs,
  inputs,
  ...
}: {
  imports = [./build-system ./development ./sources ./tests];
}
