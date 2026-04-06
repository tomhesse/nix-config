{
  brightnessctl,
  coreutils,
  gawk,
  gnused,
  libnotify,
  wireplumber,
  writeShellApplication,
}:
writeShellApplication {
  name = "media-ctl";
  runtimeInputs = [
    brightnessctl
    coreutils
    gawk
    gnused
    libnotify
    wireplumber
  ];
  text = ''
    notify_volume() {
      local device="$1" icon="$2" tag="$3" label="$4"
      vol="$(wpctl get-volume "$device")"
      pct="$(awk '{printf("%d\n", $2*100 + 0.5)}' <<<"$vol")"
      state="$(awk '{print $3}' <<<"$vol" | sed 's/\[MUTED\]/Muted/')"
      notify-send \
        --icon "$icon" \
        --hint "string:x-dunst-stack-tag:$tag" \
        --hint "int:value:$pct" \
        --expire-time 1000 \
        "$label" \
        "''${state//$'\n'/}"
    }

    notify_brightness() {
      local raw="$1"
      pct="$(awk -F, '{gsub(/"/,"",$4); gsub(/%/,"",$4); print $4}' <<<"$raw")"
      notify-send \
        --icon brightness \
        --hint "string:x-dunst-stack-tag:brightness" \
        --hint "int:value:$pct" \
        --expire-time 1000 \
        "Brightness"
    }

    case "''${1:-}" in
      volume)
        case "''${2:-}" in
          up)   wpctl set-volume --limit 1 @DEFAULT_AUDIO_SINK@ 5%+ ;;
          down) wpctl set-volume --limit 1 @DEFAULT_AUDIO_SINK@ 5%- ;;
          mute) wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle ;;
          *)    echo "Usage: media-ctl volume up|down|mute" >&2; exit 1 ;;
        esac
        notify_volume @DEFAULT_AUDIO_SINK@ multimedia-volume-control volume Volume
        ;;
      mic)
        case "''${2:-}" in
          toggle) wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle ;;
          mute)   wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 1 ;;
          unmute) wpctl set-mute @DEFAULT_AUDIO_SOURCE@ 0 ;;
          *)      echo "Usage: media-ctl mic toggle|mute|unmute" >&2; exit 1 ;;
        esac
        notify_volume @DEFAULT_AUDIO_SOURCE@ audio-input-microphone microphone Microphone
        ;;
      brightness)
        case "''${2:-}" in
          up)   raw="$(brightnessctl set 5%+ -m)" ;;
          down) raw="$(brightnessctl set 5%- -m)" ;;
          *)    echo "Usage: media-ctl brightness up|down" >&2; exit 1 ;;
        esac
        notify_brightness "$raw"
        ;;
      *)
        echo "Usage: media-ctl volume|mic|brightness ..." >&2
        exit 1
        ;;
    esac
  '';
}
