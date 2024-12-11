_: {
  services.comin = {
    enable = true;
    remotes = [
      {
        name = "origin";
        url = "https://github.com/Dauliac/jardin.git";
        branches.main.name = "main";
      }
    ];
  };
}
