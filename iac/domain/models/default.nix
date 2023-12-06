{ }: {
  bootstraps = import ./bootstrap/default.nix cluster;
  networks = import ./networks/default.nix cluster;
  accounts = import ./accounts/default.nix cluster;
  plarforms = import ./platforms/default.nix cluster;
  applications = import ./applications/default.nix cluster;
}
