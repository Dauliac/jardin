{cluster}: let
  bootstrap = import ./bootstrap.nix {inherit cluster;};
  nodeTasks = import ./node-tasks.nix {inherit cluster;};
  buildBinName = import ./build-bin-name.nix;
  dns = {
    bin = buildBinName "dns"; # TODO: add ulid generator here
  };
  authenticationApplication =
    import ./authentication-application.nix {inherit cluster;};
  storageApplication = import ./storage-application.nix {inherit cluster;};
in
  {
    inherit dns bootstrap;
    apps.auth = authenticationApplication;
    apps.storage = storageApplication;
  }
  // nodeTasks
