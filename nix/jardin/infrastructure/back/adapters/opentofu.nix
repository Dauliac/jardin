{ config, ... }: {
  imports = [ ./job.nix ];
  config.flake = {
    lib.jardin.infra.mkTerraformJob =
      { lib
      , opentofuPkgs
      , name
      , terraformConfiguration
      ,
      }:
      config.flake.lib.jardin.infra.mkJob {
        inherit lib name;
        runTimeDependencies = opentofuPkgs;
        files = [ terraformConfiguration ];
        tasks = {
          initTasks = { "init:terraform" = { cmds = [ "${command} init" ]; }; };
          runCommand = "${opentofuPkgs}/bin/tofu apply -auto-approve";
        };
      };
  };
}
