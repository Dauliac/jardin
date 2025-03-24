{ pkgs, ... }:
{
  imports = [
    ./auditd.nix
    ./comin.nix
    ./nix.nix
    ./boot.nix
    ./kubernetes.nix
    ./theme.nix
    ./networking.nix
    ./sshd.nix
    ./graphical
    ./android.nix
    ./users.nix
    ./logind.nix
    ./sleep.nix
    ./sops.nix
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
  ];
}
