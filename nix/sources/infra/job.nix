{
  flake-parts-lib,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption mdDoc types mkIf mkMerge;
  inherit (flake-parts-lib) mkPerSystemOption;
  cfg = config.infra.job;
in {
  options = {
    infra.job = {
      mkTaskfileStruct = mkOption {
        description = mdDoc "Create tasfile job manifest";
        internal = true;
        default = {
          tasks,
          files,
        }: let
          silent = true;
          internal = true;
          run = "once";
          initDeps = lib.attrNames tasks.initTasks;
          initTasks' =
            builtins.mapAttrs
            (name: value:
              value
              // {
                inherit silent internal run;
                sources = files;
              })
            tasks.initTasks;
        in {
          version = "3";
          set = ["errexit" "pipefail" "nounset"];
          shopt = ["globstar"];
          tasks =
            {
              init = {
                inherit silent internal run;
                deps = initDeps;
              };
              run = {
                inherit silent internal run;
                deps = ["init"];
                cmds = [tasks.runCommand];
              };
              default = {
                run = "once";
                deps = ["run"];
              };
            }
            // initTasks';
        };
      };
      mkTaskfile = mkOption {
        description = mdDoc "Serialize tasfile job manifest";
        internal = true;
        default = args: builtins.toJSON (cfg.lib.mkTaskfileStruct args);
      };
    };
    perSystem = mkPerSystemOption ({
      config,
      lib,
      pkgs,
      ...
    }: {
      options = {
        infra.job = {
          mkTaskfileFile = mkOption {
            description = mdDoc "Create tasfile job manifest";
            internal = true;
            default = args:
              pkgs.writeText "Taskfile.json" (cfg.mkTaskfile args);
          };
          mkJob = mkOption {
            description = mdDoc "Create a cluster job";
            default = args @ {
              name,
              runTimeDependencies,
              files,
              tasks,
            }: let
              inherit
                (pkgs)
                go-task
                coreutils
                podman
                runtimeShell
                cacert
                writeBashBin
                buildLayeredImage
                writeText
                ;
              bashStrictModeCmd = "set -o errexit -o nounset -o pipefail";
              depsPath = lib.makeBinPath runTimeDependencies;
              filesStr = builtins.concatStringsSep " " (map (s: s) files);
              taskfile = cfg.mkTaskfileFile {inherit tasks files;};
              workingDir = "working";
              buildDir = "build";
              tmpDir = "tmp";
              scriptContent = ''
                ${bashStrictModeCmd}
                export PATH=${depsPath}''${PATH:+:''${PATH}}
                cp -fr ${buildDir}/. ${workingDir}/
                ${go-task}/bin/task --taskfile /${workingDir}/Taskfile.json
              '';
              containerName = "job-${name}";
              containerTag = "none";
              jobScript = writeBashBin name scriptContent;
              container = buildLayeredImage {
                name = containerName;
                tag = containerTag;
                fakeRootCommands = ''
                  #!${runtimeShell}
                  ${bashStrictModeCmd}
                  export PATH=${depsPath}''${PATH:+:''${PATH}}
                  mkdir -p \
                    ${tmpDir} \
                    ${buildDir}
                  chmod 1777 ${tmpDir}
                  cp -f ${filesStr} ${buildDir}/
                  cp -f ${taskfile} ${buildDir}/Taskfile.json
                  chmod 111 ${buildDir}/*
                '';
                contents =
                  [go-task coreutils cacert jobScript]
                  ++ runTimeDependencies;
                config = {Cmd = ["${jobScript}/bin/${name}"];};
              };
              hash =
                builtins.hashString "sha256" (builtins.toString container);
              hostCacheDir = "/tmp/jardin-job-${name}-${hash}";
              hostWorkingDir = "${hostCacheDir}/${workingDir}";
            in
              writeBashBin name ''
                ${bashStrictModeCmd}
                ${podman}/bin/podman load --quiet --input ${container}
                ${coreutils}/bin/mkdir -p ${hostWorkingDir}
                ${podman}/bin/podman run \
                  --rm \
                  --volume ${hostWorkingDir}:/${workingDir} \
                  ${containerName}:${containerTag}
              '';
          };
        };
      };
    });
  };
  config = {flake = {lib.infra.job = cfg;};};
}
