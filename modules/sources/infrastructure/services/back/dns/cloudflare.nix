{ lib, pkgs, inputs, system }: {
  configure = { model }: {
    mkJob = { name }:
      let
        jobService = import ../adapters/terraform.nix { inherit lib pkgs; };
        # TODO: build terraform from config
        records = model.mkRecords { inherit model; };
        terraformConfiguration = inputs.terranix.lib.terranixConfiguration {
          inherit system;
          modules = [{
            resource.local_file.test_import = {
              filename = "test_import.txt";
              content = "A terranix created test file using imports. YEY!";
            };
          }];

        };
      in
      jobService.mkJob { inherit name terraformConfiguration; };
  };
}
