{ pkgs, ... }:
{
  imports = [
    ./android.nix
    ./auditd.nix
    ./boot.nix
    ./comin.nix
    ./disko.nix
    ./graphical
    ./jellyfin.nix
    ./kubernetes.nix
    ./logind.nix
    ./modules
    ./networking.nix
    ./nix.nix
    ./sleep.nix
    ./sops.nix
    ./sshd.nix
    ./theme.nix
    ./users.nix
  ];
  system.stateVersion = "24.11";
  zramSwap.enable = true;
  time.timeZone = "Europe/Paris";
  environment.systemPackages = with pkgs; [
    git
    curl
    htop
    systemctl-tui
    unzip
    fd
    vim
    htop
    runc
    cri-tools
    nvidia-container-toolkit
    nerdctl
  ];
}
