{ pkgs, ... }: {
  imports = [
    ./auditd.nix
    ./comin.nix
    ./common.nix
    ./k3s.nix
    ./networking.nix
    ./nix-snapshotter.nix
    ./sshd.nix
  ];
  system.stateVersion = "23.11";
  zramSwap.enable = true;
  environment.systemPackages = with pkgs; [
    git
    curl
    htop
    systemctl-tui
    unzip
    fd
    vim
  ];
}
