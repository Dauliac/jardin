_:
let
  disksModel = import ./disks.nix;
in
{
  configure = { nodes }: { disks = disksModel.configure { inherit nodes; }; };
}
