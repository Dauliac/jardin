{ lib, ... }:
let
  inherit (lib) mkOption mdDoc types mkIf mkMerge;
in
{
  config = {
    flake = {
      lib = mkMerge [
        {
          mkJob =
            args @ { lib
            , pkgs
            , name
            , runTimeDependencies
            , files
            , tasks
            ,
            }:
            let
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
              mkTaskfileStruct =
                { tasks
                , files
                ,
                }:
                let
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
                in
                {
                  version = "3";
                  set = [ "errexit" "pipefail" "nounset" ];
                  shopt = [ "globstar" ];
                  tasks =
                    {
                      init = {
                        inherit silent internal run;
                        deps = initDeps;
                      };
                      run = {
                        inherit silent internal run;
                        deps = [ "init" ];
                        cmds = [ tasks.runCommand ];
                      };
                      default = {
                        run = "once";
                        deps = [ "run" ];
                      };
                    }
                    // initTasks';
                };
              mkTaskfile = args: builtins.toJSON (mkTaskfileStruct args);
              mkTaskfileFile = args: writeText "Taskfile.json" (mkTaskfile args);

              depsPath = lib.makeBinPath runTimeDependencies;
              filesStr = builtins.concatStringsSep " " (map (s: s) files);
              taskfile = mkTaskfileFile { inherit tasks files; };
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
                  [ go-task coreutils cacert jobScript ]
                  ++ runTimeDependencies;
                config = { Cmd = [ "${jobScript}/bin/${name}" ]; };
              };
              hash = builtins.hashString "sha256" (builtins.toString container);
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
        }
      ];
    };
  };
}
