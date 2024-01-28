{ lib
, pkgs
, inputs
, system
,
}: {
  operations = import ./operations { inherit lib pkgs inputs system; };
}
