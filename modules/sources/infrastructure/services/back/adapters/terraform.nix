{ lib, pkgs, }:
let
  job = import ./job.nix { inherit pkgs lib; };
  command = "${pkgs.opentofu}/bin/tofu";
in
{
  mkJob = { name, terraformConfiguration }:
    job.mkJob {
      inherit name;
      runTimeDependencies = [ pkgs.opentofu ];
      files = [ terraformConfiguration ];
      command =
        [ "${command}" "init" "&&" "${command}" "apply" "-auto-approve" ];
    };
}
