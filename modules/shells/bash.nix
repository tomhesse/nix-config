{
  flake.modules.nixos.bash = {
    programs.bash.completion.enable = true;
  };

  flake.modules.homeManager.bash =
    { config, ... }:
    {
      home.persistence."/persistent".directories = [
        "${config.xdg.relativeStateHome}/bash"
      ];

      programs.bash = {
        enable = true;
        historyFile = "${config.xdg.stateHome}/bash/history";
        historyControl = [
          "erasedups"
          "ignoredups"
          "ignorespace"
        ];
        initExtra = ''
          PROMPT_COMMAND='printf "\033]0;%s\007" "''${PWD/#$HOME/\~}"'
        '';
      };
    };
}
