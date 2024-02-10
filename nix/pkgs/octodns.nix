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
  buildOctoDnsPackage =
    { name
    , version
    , description
    , hash
    , maintainers
    , octodns
    ,
    }:
    let
      title = "octodns";
    in
    buildPythonPackage rec {
      inherit version;
      pname = "${title}-${name}";
      pyproject = true;

      disabled = pythonOlder "3.8";

      src = fetchFromGitHub {
        owner = "${title}";
        repo = "${title}-${name}";
        rev = "v${version}";
        inherit hash;
      };

      nativeBuildInputs = [ setuptools ];

      propagatedBuildInputs = [ octodns dnspython ];

      env.OCTODNS_RELEASE = 1;

      pythonImportsCheck = [ "${title}_${name}" ];

      nativeCheckInputs = [ pytestCheckHook ];

      meta = with lib; {
        inherit description maintainer;
        homepage = "https://github.com/${title}/${pname}";
        changelog = "https://github.com/${title}/${pname}/blob/${src.rev}/CHANGELOG.md";
        license = licenses.mit;
      };
    };
in
{
  octodnsCloudflare = buildOctoDnsPackage {
    inherit octodns;
    name = "cloudflare";
    version = "0.0.4";
    hash = "sha256-0ia/xYarrOiLZa8KU0s5wtCGtXIyxSl6OcwNkSJb/rA=";
    description = "An octoDNS provider that targets Cloudflare.";
    maintainers = with maintainers; [ "dauliac" ];
  };
}
