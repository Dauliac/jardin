_: {
  sops = {
    age.keyFile = "/home/admin/.config/sops/age/key.txt";
    defaultSopsFile = ../../secrets.sops.yaml;
    secrets = {
      domain = { };
      admin_hashed_password = { };
    };
  };
}
