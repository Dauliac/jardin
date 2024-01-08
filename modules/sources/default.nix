{ ... }: {
  perSystem = { system, pkgs, self', ... }: {
    lib = {
      echoLa = name:
        pkgs.writeShellScript name ''
          #!/usr/bin/env bash
          echo coucou
        '';
    };
  };
}
