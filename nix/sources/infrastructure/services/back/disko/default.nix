{ lib
, pkgs
, inputs
, system
,
}: {
  configure = { clusterModel }: {
    mkNixOs = _: (import ./disks.nix { inherit disksModels; });
  };
}
