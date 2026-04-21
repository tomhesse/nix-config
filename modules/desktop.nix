{ self, ... }:
{
  flake.modules.nixos.desktop = {
    imports = [
      self.modules.nixos.base
      self.modules.nixos.firefox
      self.modules.nixos.gamescope
      self.modules.nixos.hyprland
      self.modules.nixos.monitors
      self.modules.nixos.nixpkgs
      self.modules.nixos.pipewire
      self.modules.nixos.plymouth
      self.modules.nixos.sddm
      self.modules.nixos.steam
      self.modules.nixos.wireless
      self.modules.nixos.yubikey
      self.modules.nixos.zen-kernel
    ];

  };

  flake.modules.homeManager.desktop = {
    imports = [
      self.modules.homeManager.abcde
      self.modules.homeManager.aerc
      self.modules.homeManager.base
      self.modules.homeManager.beets
      self.modules.homeManager.claude
      self.modules.homeManager.cliphist
      self.modules.homeManager.dunst
      self.modules.homeManager.firefox
      self.modules.homeManager.fonts
      self.modules.homeManager.hypridle
      self.modules.homeManager.hyprland
      self.modules.homeManager.hyprlock
      self.modules.homeManager.hyprpaper
      self.modules.homeManager.hyprsunset
      self.modules.homeManager.imv
      self.modules.homeManager.kitty
      self.modules.homeManager.mpd
      self.modules.homeManager.mpv
      self.modules.homeManager.ncmpcpp
      self.modules.homeManager.obsidian
      self.modules.homeManager.osu
      self.modules.homeManager.pipewire
      self.modules.homeManager.playerctld
      self.modules.homeManager.rofi
      self.modules.homeManager.steam
      self.modules.homeManager.trash
      self.modules.homeManager.utilities
      self.modules.homeManager.vesktop
      self.modules.homeManager.wallpaper
      self.modules.homeManager.waybar
      self.modules.homeManager.xdg-autostart
      self.modules.homeManager.xdg-user-dirs
      self.modules.homeManager.zathura
      self.modules.homeManager.zed
    ];
  };
}
