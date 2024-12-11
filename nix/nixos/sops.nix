_: {
  sops = {
    age.keyFile = "/tmp/sops.txt";
    # defaultSopsFile = ../../secrets.yaml;
    secrets.openai_key = {};
    secrets.dauliac_hashed_password = {};
  };
}
