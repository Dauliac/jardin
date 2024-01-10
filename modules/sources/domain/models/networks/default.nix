{ cluster }: {
  backbone = import ./backbone/default.nix cluster.targets;
  dns = import ./dns/default.nix cluster;
}
