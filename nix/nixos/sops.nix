_: {
  sops = {
    age.keyFile = "/home/jardin/.config/sops/age/dotfiles.txt";
    # defaultSopsFile = ../../secrets.yaml;
    secrets.openai_key = { };
    secrets.dauliac_hashed_password = { };
  };
}
