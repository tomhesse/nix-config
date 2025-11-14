{
  brightnessctl,
  coreutils,
  gawk,
  gnused,
  lib,
  libnotify,
  symlinkJoin,
  wireplumber,
  writeShellApplication,
}:

let
  volume-up = writeShellApplication {
    name = "volume-up";
    runtimeInputs = [
      coreutils
      gawk
      gnused
      libnotify
      wireplumber
    ];
    text = ''
      wpctl set-volume --limit 1 @DEFAULT_AUDIO_SINK@ 5%+
      VOL="$(wpctl get-volume '@DEFAULT_AUDIO_SINK@')"
      PCT="$(awk '{printf("%d\n", $2*100 + 0.5)}' <<<"$VOL")"
      STATE="$(awk '{print $3}' <<<"$VOL" | sed 's/\[MUTED\]/Muted/')"
      notify-send \
        --icon multimedia-volume-control \
        --hint string:x-dunst-stack-tag:volume \
        --hint int:value:"''${PCT}" \
        --expire-time 1000 \
        "Volume" \
        "''${STATE//$'\n'/}"
    '';
  };

  volume-down = writeShellApplication {
    name = "volume-down";
    runtimeInputs = [
      coreutils
      gawk
      gnused
      libnotify
      wireplumber
    ];
    text = ''
      wpctl set-volume --limit 1 @DEFAULT_AUDIO_SINK@ 5%-
      VOL="$(wpctl get-volume '@DEFAULT_AUDIO_SINK@')"
      PCT="$(awk '{printf("%d\n", $2*100 + 0.5)}' <<<"$VOL")"
      STATE="$(awk '{print $3}' <<<"$VOL" | sed 's/\[MUTED\]/Muted/')"
      notify-send \
        --icon multimedia-volume-control \
        --hint string:x-dunst-stack-tag:volume \
        --hint int:value:"''${PCT}" \
        --expire-time 1000 \
        "Volume" \
        "''${STATE//$'\n'/}"
    '';
  };

  volume-mute = writeShellApplication {
    name = "volume-mute";
    runtimeInputs = [
      coreutils
      gawk
      gnused
      libnotify
      wireplumber
    ];
    text = ''
      wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
      VOL="$(wpctl get-volume '@DEFAULT_AUDIO_SINK@')"
      PCT="$(awk '{printf("%d\n", $2*100 + 0.5)}' <<<"$VOL")"
      STATE="$(awk '{print $3}' <<<"$VOL" | sed 's/\[MUTED\]/Muted/')"
      notify-send \
        --icon multimedia-volume-control \
        --hint string:x-dunst-stack-tag:volume \
        --hint int:value:"''${PCT}" \
        --expire-time 1000 \
        "Volume" \
        "''${STATE//$'\n'/}"
    '';
  };

  mic-mute = writeShellApplication {
    name = "mic-mute";
    runtimeInputs = [
      coreutils
      gawk
      gnused
      libnotify
      wireplumber
    ];
    text = ''
      wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle
      VOL="$(wpctl get-volume '@DEFAULT_AUDIO_SOURCE@')"
      PCT="$(awk '{printf("%d\n", $2*100 + 0.5)}' <<<"$VOL")"
      STATE="$(awk '{print $3}' <<<"$VOL" | sed 's/\[MUTED\]/Muted/')"
      notify-send \
        --icon audio-input-microphone \
        --hint string:x-dunst-stack-tag:microphone \
        --hint int:value:"''${PCT}" \
        --expire-time 1000 \
        "Microphone" \
        "''${STATE//$'\n'/}"
    '';
  };

  brightness-up = writeShellApplication {
    name = "brightness-up";
    runtimeInputs = [
      brightnessctl
      coreutils
      gawk
      gnused
      libnotify
    ];
    text = ''
      RAW="$(brightnessctl set 5%+ -m)"
      PCT="$(awk -F, '{gsub(/"/,"",$4); gsub(/%/,"",$4); print $4}' <<<"$RAW")"
      notify-send \
        --icon brightness \
        --hint string:x-dunst-stack-tag:brightness \
        --hint int:value:"''${PCT}" \
        --expire-time 1000 \
        "Brightness"
    '';
  };

  brightness-down = writeShellApplication {
    name = "brightness-down";
    runtimeInputs = [
      brightnessctl
      coreutils
      gawk
      gnused
      libnotify
    ];
    text = ''
      RAW="$(brightnessctl set 5%- -m)"
      PCT="$(awk -F, '{gsub(/"/,"",$4); gsub(/%/,"",$4); print $4}' <<<"$RAW")"
      notify-send \
        --icon brightness \
        --hint string:x-dunst-stack-tag:brightness \
        --hint int:value:"''${PCT}" \
        --expire-time 1000 \
        "Brightness"
    '';
  };
in
symlinkJoin {
  name = "dunst-scripts";
  paths = [
    brightness-down
    brightness-up
    mic-mute
    volume-down
    volume-mute
    volume-up
  ];

  meta = {
    homepage = "https://github.com/tomhess/nix-config";
    description = "Scripts to change volume and brightness with a fancy progress bar using dunst.";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ tomhesse ];
    platforms = lib.platforms.linux;
  };
}
