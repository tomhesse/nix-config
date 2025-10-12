{ config, inputs, ... }:
{
  imports = [ inputs.impermanence.homeManagerModules.impermanence ];

  home.persistence."/persist/${config.home.homeDirectory}" = {
    allowOther = true;
  };
}
