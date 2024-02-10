{ flake-parts-lib
, config
, pkgs
, inputs
, ...
}: {
  perSystem =
    { config
    , self'
    , inputs'
    , pkgs
    , ...
    }:
    let
      octdnsPackages = import ./octodns.nix;
    in
    {
      packages = {
        octodns-cloudflare = pkgs.python3.withPackages (ps: [
          octdnsPackages
          {
            inherit
              (pkgs)
              lib
              fetchFromGitHub
              octodns
              pytestCheckHook
              pythonOlder
              ;
            inherit
              (pkgs.python312Packages)
              setuptoolsbuildPythonPackage
              dnspython
              ;
          }
        ]);
      };
    };
}
