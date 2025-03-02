_: {
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    extraConfig = ''
      HandleLidSwitch=ignore
      HandleLidSwitchExternalPower=ignore
      HandleLidSwitchDocked=ignore
      IdleAction=ignore
      IdleActionSec=0
    '';
  };
}
