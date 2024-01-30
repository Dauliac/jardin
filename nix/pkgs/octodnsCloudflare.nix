{ lib
, buildPythonPackage
, fetchFromGitHub
, octodns
, pytestCheckHook
, pythonOlder
, dnspython
, setuptools
,
}:
let
  inherit (lib) maintainers;
  buildOctoPackage =
    { name
    , version
    , description
    , hash
    , octodns
    ,
    }:
    buildPythonPackage rec {
      inherit version;
      pname = "octodns-${name}";
      pyproject = true;

      disabled = pythonOlder "3.8";

      src = fetchFromGitHub {
        owner = "octodns";
        repo = "octodns-${name}";
        rev = "v${version}";
        inherit hash;
      };

      nativeBuildInputs = [ setuptools ];

      propagatedBuildInputs = [ octodns dnspython ];

      env.OCTODNS_RELEASE = 1;

      pythonImportsCheck = [ "octodns_${name}" ];

      nativeCheckInputs = [ pytestCheckHook ];

      meta = with lib; {
        inherit description maintainer;
        homepage = "https://github.com/octodns/octodns-${name}";
        changelog = "https://github.com/octodns/octodns-${name}/blob/${src.rev}/CHANGELOG.md";
        license = licenses.mit;
      };
    };
in
{
  octodnsCloudflare = buildOctoPackage {
    inherit octodns;
    name = "cloudflare";
    version = "0.0.4";
    hash = "sha256-0ia/xYarrOiLZa8KU0s5wtCGtXIyxSl6OcwNkSJb/rA=";
    description = " An octoDNS provider that targets Cloudflare.";
    maintainers = with maintainers; [ "dauliac" ];
  };
}
