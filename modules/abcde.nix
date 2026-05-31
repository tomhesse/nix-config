{
  flake.modules.homeManager.abcde =
    { config, pkgs, ... }:
    let
      outputFormat = "\${ARTISTFILE}/\${ALBUMFILE}/\${TRACKNUM} - \${TRACKFILE}";
      vaOutputFormat = "Various Artists/\${ALBUMFILE}/\${TRACKNUM} - \${ARTISTFILE} - \${TRACKFILE}";

      abcdeConfig = ''
        OUTPUTTYPE="flac"
        FLACOPTS='--silent --exhaustive-model-search --verify --compression-level-8'

        CDPARANOIAOPTS="--never-skip=40"

        OUTPUTDIR="${config.xdg.userDirs.extraConfig.TEMP}/rips"
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

      wrappedAbcde = pkgs.symlinkJoin {
        name = "abcde";
        paths = [ pkgs.abcde ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/abcde \
            --add-flags "-c ${config.xdg.configHome}/abcde.conf"
        '';
      };
    in
    {
      home.packages = [ wrappedAbcde ];

      xdg.configFile."abcde.conf".text = abcdeConfig;
    };
}
