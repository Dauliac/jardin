_: {
  services.openssh = {
    enable = true;
    allowSFTP = false;
    settings = {
      PasswordAuthentication = false;
    };
  };
}
