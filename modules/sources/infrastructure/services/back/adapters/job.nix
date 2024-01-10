{ lib, pkgs, }: {
  mkJob = args@{ name, runTimeDependencies, files, command, ... }:
    let
      cmdLib = import ../../../services/adapters/command.nix { };
      commandStr = builtins.concatStringsSep " " (map (s: s) command);
      depsPath = lib.makeBinPath runTimeDependencies;
      filesStr = builtins.concatStringsSep " " (map (s: s) files);
      # TODO: keep initial terraform in cache ?
      scriptContent = ''
        set -o errexit -o nounset -o pipefail
        export PATH=${depsPath}''${PATH:+:''${PATH}}
        cp -f ${filesStr} .
        cat ${filesStr}
        ${commandStr}
      '';
      containerName = "job-${name}";
      containerTag = "none";
      jobScript = pkgs.writers.writeBashBin name scriptContent;
      container = pkgs.dockerTools.buildLayeredImage {
        name = containerName;
        tag = containerTag;
        fakeRootCommands = ''
          #!${pkgs.runtimeShell}
          mkdir -p tmp
          chmod 1777 tmp
        '';
        contents = [ pkgs.coreutils pkgs.cacert jobScript ]
          ++ runTimeDependencies;
        config = { Cmd = [ "${jobScript}/bin/${name}" ]; };
      };
      hash = builtins.hashString "sha256" (builtins.toString container);
      tmpDir = "/tmp/jardin-job-${name}-${hash}";
      # TODO: export it in parent function
      terraformTmpDir = "${tmpDir}/terraform";
      tmpTmpDir = "${tmpDir}/tmp";
    in
    pkgs.writers.writeBashBin name ''
      set -o errexit -o nounset -o pipefail
      ${pkgs.podman}/bin/podman load --quiet --input ${container}
      ${pkgs.coreutils}/bin/mkdir -p \
        ${terraformTmpDir} \
        ${tmpTmpDir}
      ${pkgs.podman}/bin/podman run \
        --rm \
        --volume ${terraformTmpDir}/:/.terraform/ \
        --volume ${tmpTmpDir}/:/tmp/ \
        ${containerName}:${containerTag}
    '';
}
