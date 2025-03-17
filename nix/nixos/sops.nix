_: {
  sops = {
    age.keyFile = "/home/admin/.config/sops/age/key.txt";
    defaultSopsFile = ../../secrets.sops.yaml;
    secrets = {
      domain = { };
      admin_hashed_password = { };
      lets_encrypt_email = { };
      lets_encrypt_server = { };
    };
  };
}
