{pkgs}: {
  deploy = {config}: import ./deploy/default.nix {inherit pkgs config;};
}
