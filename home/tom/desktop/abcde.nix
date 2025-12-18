{ config, pkgs, ... }:
let
  outputFormat = "\${ARTISTFILE}/\${ALBUMFILE}/\${TRACKNUM}. \${TRACKFILE}";
  vaOutputFormat = "Various-\${ALBUMFILE}/\${TRACKNUM}. \${ARTISTFILE}-\${TRACKFILE}";
  oneTrackOutputFormat = "\${ARTISTFILE}-\${ALBUMFILE}/\${ALBUMFILE}";
  vaOneTrackOutputFormat = "Various-\${ALBUMFILE}/\${ALBUMFILE}";
  playlistFormat = "\${OUTPUT}/\${ARTISTFILE}-\${ALBUMFILE}/\${ALBUMFILE}.m3u";
  vaPlaylistFormat = "\${OUTPUT}/Various-\${ALBUMFILE}/\${ALBUMFILE}.m3u";

  abcdeConfig = ''
    ACTIONS=default,replaygain

    OUTPUTTYPE="flac"
    FLACOPTS='--silent --exhaustive-model-search --verify --compression-level-8'

    CDPARANOIAOPTS="--never-skip=40"

    OUTPUTDIR="${config.xdg.userDirs.extraConfig.XDG_TEMP_DIR}/music"
    WAVOUTPUTDIR="/tmp"

    OUTPUTFORMAT='${outputFormat}'
    VAOUTPUTFORMAT='${vaOutputFormat}'

    ONETRACKOUTPUTFORMAT='${oneTrackOutputFormat}'
    VAONETRACKOUTPUTFORMAT='${vaOneTrackOutputFormat}'

    PLAYLISTFORMAT='${playlistFormat}'
    VAPLAYLISTFORMAT='${vaPlaylistFormat}'

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
