{ lib
, pkgs
,
}:
let
  job = import ./job.nix { inherit pkgs lib; };
  command = "${pkgs.opentofu}/bin/tofu";
in
{
  mkJob =
    { name
    , terraformConfiguration
    ,
    }:
    job.mkJob {
      inherit name;
      runTimeDependencies = [ pkgs.opentofu ];
      files = [ terraformConfiguration ];
      tasks = {
        initTasks = { "init:terraform" = { cmds = [ "${command} init" ]; }; };
        runCommand = "${command} apply -auto-approve";
      };
    };
}
