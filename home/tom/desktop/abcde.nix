{ config, pkgs, ... }:
let
  outputFormat = "\${ARTISTFILE}/\${ALBUMFILE}/\${TRACKNUM} - \${TRACKFILE}";
  vaOutputFormat = "Various Artists/\${ALBUMFILE}/\${TRACKNUM} - \${ARTISTFILE} - \${TRACKFILE}";

  abcdeConfig = ''
    ACTIONS=default,replaygain

    OUTPUTTYPE="flac"
    FLACOPTS='--silent --exhaustive-model-search --verify --compression-level-8'

    CDPARANOIAOPTS="--never-skip=40"

    OUTPUTDIR="${config.xdg.userDirs.extraConfig.XDG_TEMP_DIR}/rips"
    WAVOUTPUTDIR="/tmp"

    OUTPUTFORMAT='${outputFormat}'
    VAOUTPUTFORMAT='${vaOutputFormat}'

    ONETRACKOUTPUTFORMAT="$OUTPUTFORMAT"
    VAONETRACKOUTPUTFORMAT="$VAOUTPUTFORMAT"

    mungefilename () {
      echo "$@" | sed -e 's/^\.*//' | tr -d ":><|*/\"'?[:cntrl:]"
    }

    LOWDISK=y
    MAXPROCS=4
    PADTRACKS=y
    COMMENT="abcde version ${pkgs.abcde.version}"
    EJECTCD=y
  '';
in
{
  home.packages = [ pkgs.abcde ];

  home.file.".abcde.conf".text = abcdeConfig;
}
