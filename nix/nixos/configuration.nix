{ pkgs, ... }:
{
  imports = [
    ./auditd.nix
    ./comin.nix
    ./nix.nix
    ./boot.nix
    # ./k3s.nix
    ./theme.nix
    ./networking.nix
    ./nix-snapshotter.nix
    ./sshd.nix
    ./graphical
    ./android.nix
    ./users.nix
    ./logind.nix
    ./sleep.nix
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
  ];
}
