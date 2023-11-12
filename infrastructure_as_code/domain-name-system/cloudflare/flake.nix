{
  description = "Jardin dns cloudflare plugin service";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    # TODO: input from jardin
  };
  outputs =
    { self
    , nixpkgs
    }:
    {
      cluster = import ./flake.nix;
      deploy = utils.map (cluster,... );
      # nix echo '{ token: "xxxxxx"; zone_id = "YYYY" }' | nix run .
      # import flake.nix -> map vers l'implen deploy-rs -> nix run .
      # OPTIONS:
      #  deploy node-per-node, or all at once
      app.default = { };
      # jardin:
      # SI c'est pas un sous flake, il faut un utilitaire pour faire remonter des outputs dans le flake root
      # jardin -> pour chaque job:
      # Utiliser lolipop pour ca ?
      #  nix run jardin-deploy-provision
    };
};
