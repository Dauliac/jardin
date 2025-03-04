{
  lib,
  inputs,
  ...
}:
let
  inherit (lib) mkOption mdDoc types;
  inherit (inputs.flake-parts.lib) mkPerSystemOption;
in
{
  options.perSystem = mkPerSystemOption (
    {
      config,
      pkgs,
      ...
    }:
    {
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
    }
  );
  config.perSystem =
    {
      config,
      pkgs,
      ...
    }:
    {
      valeMicrosoft = pkgs.runCommand "vale-microsoft-links" { } ''
        ln -sf ${inputs.valeMicrosoft}/Microsoft $out
      '';
      valeJoblint = pkgs.runCommand "vale-joblint-links" { } ''
        ln -sf ${inputs.valeJoblint}/Joblint $out
      '';
      valeWriteGood = pkgs.runCommand "vale-write-good-links" { } ''
        ln -sf ${inputs.valeWriteGood}/write-good $out
      '';
      packages.mdbookMermaidStyles = pkgs.stdenv.mkDerivation {
        name = "mdbook-mermaid-styles";
        src = config.packages.mdbookConfiguration;
        dontUnpack = true;
        buildPhase = ''
          ln -sf $src book.toml
          ${pkgs.mdbook-mermaid}/bin/mdbook-mermaid install
          mkdir -p $out
          mv mermaid-init.js mermaid.min.js $out
        '';
      };
      packages.valeConfiguration = pkgs.writeText ".vale.ini" ''
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
      packages.mdbookConfiguration = pkgs.writeText "book.toml" ''
        [book]
        authors = ["jdauliac"]
        language = "en"
        multilingual = false
        src = "./docs"
        title = "Jardin technical documentation"
        description = "As code documentation, managed with mdBook, mermaid, and vale."
        [preprocessor]
        [preprocessor.index]
        renderer = ["html"]
        [preprocessor.links]
        renderer = ["html"]
        [preprocessor.footnote]
        renderer = ["html"]
        command = "${pkgs.mdbook-footnote}/bin/mdbook-footnote"
        [preprocessor.katex]
        after = ["links"]
        command = "${pkgs.mdbook-katex}/bin/mdbook-katex"
        [preprocessor.mermaid]
        command = "${pkgs.mdbook-mermaid}/bin/mdbook-mermaid"
        renderer = ["html"]
        [preprocessor.cmdrun]
        command = "${pkgs.mdbook-cmdrun}/bin/mdbook-cmdrun"
        [preprocessor.emojicodes]
        command = "${pkgs.mdbook-emojicodes}/bin/mdbook-emojicodes"
        [preprocessor.toc]
        marker = "[[_TOC_]]"
        [output]
        [output.html]
        renderer = ["html"]
        additional-js = [
          "${config.mdbookMermaidStylesPath}/mermaid.min.js",
          "${config.mdbookMermaidStylesPath}/mermaid-init.js"
        ]
        [output.linkcheck]
        renderer = ["html"]
        follow-web-links = true
      '';
      documentationShellHookScript = ''
        export FLAKE_ROOT="$(git rev-parse --show-toplevel)"
        rm -rf \
          "$FLAKE_ROOT/${config.valeStylesPath}/Microsoft" \
          "$FLAKE_ROOT/${config.valeStylesPath}/Joblint" \
          "$FLAKE_ROOT/${config.valeStylesPath}/write-good" \
          "$FLAKE_ROOT/${config.mdbookMermaidStylesPath}" \
          "$FLAKE_ROOT/.vale.ini"
        ln -s ${config.valeMicrosoft} "$FLAKE_ROOT/${config.valeStylesPath}/Microsoft"
        ln -s ${config.valeJoblint} "$FLAKE_ROOT/${config.valeStylesPath}/Joblint"
        ln -s ${config.valeWriteGood} "$FLAKE_ROOT/${config.valeStylesPath}/write-good"
        ln -s ${config.packages.valeConfiguration} "$FLAKE_ROOT/.vale.ini"
        ln -s ${config.packages.mdbookConfiguration} "$FLAKE_ROOT/book.toml"
        ln -s ${config.packages.mdbookMermaidStyles} "$FLAKE_ROOT/${config.mdbookMermaidStylesPath}"
      '';
    };
}
