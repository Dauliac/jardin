{ config
, lib
, pkgs
, inputs
, ...
}: {
  perSystem =
    { system
    , pkgs
    , self'
    , ...
    }:
    let
      application = import ./application { inherit lib pkgs inputs system; };
      inherit (application.services.operations) deploy;
      inherit (application.services) serialize;
    in
    { lib = { inherit deploy serialize; }; };
}
