# SPDX-License-Identifier: AGPL-3.0-or-later
{
  lib,
  inputs,
  ...
}: let
  inherit (lib) mkOption mdDoc types;
  inherit (inputs.flake-parts.lib) mkPerSystemOption;
in {
  options.perSystem =
    mkPerSystemOption
    ({
      config,
      pkgs,
      ...
    }: {
      options = {
        valeStylesPath = mkOption {
          description = mdDoc "The path to the vale style";
          type = types.singleLineStr;
          default = "./docs/styles";
        };
        mdbookMermaidStylesPath = mkOption {
          description = mdDoc "The path to the mdbook mermaid style";
          type = types.singleLineStr;
          default = "./docs/mermaid";
        };
        valeMicrosoft = mkOption {
          description = mdDoc "The vale Microsoft style";
          type = types.package;
        };
        valeJoblint = mkOption {
          description = mdDoc "The vale Joblint style";
          type = types.package;
        };
        valeWriteGood = mkOption {
          description = mdDoc "The vale Write-Good style";
          type = types.package;
        };
        mdbookMermaidStyles = mkOption {
          description = mdDoc "The mdbook mermaid style assets";
          type = types.package;
        };
        valeConfiguration = mkOption {
          description = mdDoc "The vale configuration file";
          type = types.package;
        };
        documentationShellHookScript = mkOption {
          description = mdDoc "The shell hook to run in devShell";
        };
        docsPackages = mkOption {
          description = mdDoc "Packages used to generate the documentation";
          default = with pkgs; [
            tagref
            vale
            tokei
            eza
            vhs
            fd
            mdformat
            markdownlint-cli2
            mdbook
            mdbook-toc
            mdbook-cmdrun
            mdbook-emojicodes
            mdbook-footnote
            mdbook-graphviz
            mdbook-katex
            mdbook-linkcheck
            mdbook-mermaid
            mdbook-pdf
            mdbook-toc
          ];
        };
      };
    });
  config.perSystem = {
    config,
    pkgs,
    ...
  }: {
    valeMicrosoft = pkgs.runCommand "vale-microsoft-links" {} ''
      ln -s ${inputs.valeMicrosoft}/Microsoft $out
    '';
    valeJoblint = pkgs.runCommand "vale-joblint-links" {} ''
      ln -s ${inputs.valeJoblint}/Joblint $out
    '';
    valeWriteGood = pkgs.runCommand "vale-write-good-links" {} ''
      ln -s ${inputs.valeWriteGood}/write-good $out
    '';
    mdbookMermaidStyles = pkgs.stdenv.mkDerivation {
      name = "mdbook-mermaid-styles";
      src = ../.././book.toml;
      phases = ["installPhase"];
      installPhase = ''
        ln -s $src book.toml
        # ls
        # exit 1
        ${pkgs.mdbook-mermaid}/bin/mdbook-mermaid install
        mkdir -p $out
        mv mermaid-init.js mermaid.min.js $out
      '';
    };
    valeConfiguration = pkgs.writeText ".vale.ini" ''
      # SPDX-License-Identifier: AGPL-3.0-or-later
      StylesPath = styles
      MinAlertLevel = suggestion
      Packages = Microsoft, write-good, Joblint
      StylesPath = "${config.valeStylesPath}"
      Vocab = Jardin
      [./CHANGELOG.md]
      BasedOnStyles = Vale
      Vale.Spelling = NO
      Vale.terms = NO
      [*.md]
      BasedOnStyles = Vale, Microsoft, write-good, Joblint
      Microsoft.Accessibility = NO
      [*.mermaid]
      BasedOnStyles = Vale, write-good, Joblint
    '';
    documentationShellHookScript = ''
      rm -rf \
        ${config.valeStylesPath}/Microsoft \
        ${config.valeStylesPath}/Joblint \
        ${config.valeStylesPath}/write-good \
        ${config.mdbookMermaidStylesPath} \
        .vale.ini
      ln -s ${config.valeConfiguration} .vale.ini
      ln -s ${config.valeMicrosoft} ${config.valeStylesPath}/Microsoft
      ln -s ${config.valeJoblint} ${config.valeStylesPath}/Joblint
      ln -s ${config.valeWriteGood} ${config.valeStylesPath}/write-good
      ln -s ${config.mdbookMermaidStyles} ${config.mdbookMermaidStylesPath}
    '';
  };
}
