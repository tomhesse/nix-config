{
  coreutils,
  gawk,
  hyprlock,
  lib,
  rofi-wayland,
  systemd,
  uwsm,
  writeShellApplication,
}:
writeShellApplication {
  name = "power-menu";
  runtimeInputs = [
    coreutils
    gawk
    hyprlock
    rofi-wayland # TODO: Change to rofi when rofi 2.0.0 is available
    systemd
    uwsm
  ];
  text = ''
    choice="$(
      printf '%s\n' \
        '  Shutdown' \
        '  Reboot' \
        '  Suspend' \
        '  Logout' \
        '  Lock' \
      | rofi -dmenu -i -p 'Power Menu' | awk '{print $2}'
    )"

    case "$choice" in
      Shutdown)
        exec systemctl poweroff ;;
      Reboot)
        exec systemctl reboot ;;
      Suspend)
        exec systemctl suspend ;;
      Lock)
        exec hyprlock ;;
      Logout)
        exec uwsm stop ;;
      *)
        exit 0 ;;
    esac
  '';

  meta = {
    homepage = "https://github.com/tomhesse/nix-config";
    description = "Power menu using rofi.";
    mainProgram = "power-menu";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomhesse ];
    platforms = lib.platforms.linux;
  };
}
