_: {
  sops = {
    age.keyFile = "/home/admin/.config/sops/age/key.txt";
    defaultSopsFile = ../../secrets.yaml;
    secrets.admin_hashed_password = { };
  };
}
