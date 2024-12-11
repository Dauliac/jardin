{pkgs, ...}: {
  imports = [
    ./auditd.nix
    # ./comin.nix
    ./nix.nix
    ./boot.nix
    ./k3s.nix
    ./networking.nix
    ./nix-snapshotter.nix
    ./sshd.nix
    ./graphical
  ];
  system.stateVersion = "24.11";
  zramSwap.enable = true;
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
