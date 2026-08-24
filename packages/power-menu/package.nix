{
  coreutils,
  rofi,
  systemd,
  uwsm,
  writeShellApplication,
}:
writeShellApplication {
  name = "power-menu";
  runtimeInputs = [
    coreutils
    rofi
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
      | rofi -dmenu -i -p 'Power Menu' | cut -d' ' -f3
    )"

    case "$choice" in
      Shutdown) exec systemctl poweroff ;;
      Reboot)   exec systemctl reboot ;;
      Suspend)  exec systemctl suspend ;;
      Lock)     exec loginctl lock-session ;;
      Logout)   exec uwsm stop ;;
      *)        exit 0 ;;
    esac
  '';
}
