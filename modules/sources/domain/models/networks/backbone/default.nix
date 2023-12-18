{targets}: {
  wan = import ./wan.nix targets;
  lan = import ./lan.nix targets;
}
