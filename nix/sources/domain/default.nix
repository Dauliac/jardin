{
  flake-parts-lib,
  lib,
  config,
  pkgs,
  inputs,
  ...
}: let
  inherit (lib) mkOption types mdDoc mkOptionType;
  cfg = config.domain;
in {
  imports = [./network ./storage ./account];
  options = {
    domain.cluster = {
      types = {
        convertMiBTodigitalStorageUnit = mkOption {
          description = "Converts MiB int into a digital storage unit.";
          default = value: "${toString value}MiB";
        };
        convertToMiB = mkOption {
          description = "Converts the digitalStorageUnit type value to MiB.";
          default = value: let
            unitBase2Padding = 1024;
            unitBase10Padding = 1000;
            numericPart =
              builtins.head (builtins.match "([0-9.]+)[A-Za-z]+" value);
            unit = builtins.head (builtins.match "[0-9.]+([A-Za-z]+)" value);
            mbToMiBFactor = 0.95367431640625;
            multiplier =
              if unit == "TiB"
              then unitBase2Padding * unitBase2Padding
              else if unit == "GiB"
              then unitBase2Padding
              else if unit == "MiB"
              then 1
              else if unit == "TB"
              then unitBase10Padding * unitBase10Padding * mbToMiBFactor
              else if unit == "GB"
              then unitBase10Padding * mbToMiBFactor
              else if unit == "MB"
              then mbToMiBFactor
              else 1;
          in
            builtins.floor ((lib.strings.toInt numericPart) * multiplier);
        };
        digitalStorageUnit = mkOption {
          description = "Digital storage unit Size type to manage values in GB, MB, TB, GiB, MiB or TiB,.";
          default = let
            isValidFormat = value:
              builtins.match "[0-9.]+(GB|MB|TB|GiB|MiB|TiB)" value != null;
          in
            mkOptionType {
              name = "digital storage unit";
              description = "Digital storage unit size in GB, MB, TB, GiB, MiB, TiB, converted to MiB, ensuring the value is greater than 0.";
              descriptionClass = "noun";
              check = value:
                isValidFormat value && (cfg.cluster.types.convertToMiB value > 0);
              merge = loc: defs:
                lib.foldl'
                (acc: def: acc + (cfg.cluster.types.convertToMiB def.value))
                0
                defs;
            };
        };
        domainName = mkOption {
          description = "The domain name type to ensure the value is a valid domain name.";
          default = mkOptionType {
            name = "digital storage unit";
            description = "Digital storage unit computer size in GB, MB, or TB, converted to MB, ensuring the value is greater than 0.";
            descriptionClass = "noun";
            check = value:
              lib.strings.isString value
              && lib.strings.match "[a-zA-Z0-9.-]+.[a-zA-Z]{2,}$" value != null;
          };
        };
      };
      domain = mkOption {
        description = mdDoc "The root dns zone of your cluster";
        example = "supacluster.io";
        type = cfg.cluster.types.domainName;
      };
      nodes = mkOption {
        description = mdDoc "The cluster's nodes";
        type = types.attrsOf (types.submodule (_: {
          options = {
            role = mkOption {
              description = mdDoc "";
              type = types.enum ["node"];
            };
            ip = mkOption {
              description = mdDoc "";
              type = types.singleLineStr;
            };
            resources = mkOption {
              default = null;
              description = mdDoc "";
              type = types.submodule ({config, ...}: {
                options = {
                  cpu = mkOption {
                    description = mdDoc "The number of cpu cores";
                    example = "2";
                    type = types.ints.positive;
                  };
                  memory = mkOption {
                    description = mdDoc "Random access memory size";
                    example = "1024MB";
                    type = cfg.cluster.types.digitalStorageUnit;
                  };
                  storage = {
                    disks = mkOption {
                      description = mdDoc "The disks of the node";
                      type = types.listOf (types.submodule (_: {
                        options = {
                          device = mkOption {
                            description = mdDoc "The device of the disk";
                            example = "/dev/sda";
                            type = types.singleLineStr;
                          };
                          size = mkOption {
                            description = mdDoc "The size of the disk";
                            example = "20GB";
                            type = cfg.cluster.types.digitalStorageUnit;
                          };
                        };
                      }));
                    };
                    uefi = mkOption {
                      description = mdDoc "Is the node have uefi";
                      type = types.bool;
                    };
                  };
                };
              });
            };
          };
        }));
      };
    };
  };
  config = {flake = {lib.domain = cfg;};};
}
