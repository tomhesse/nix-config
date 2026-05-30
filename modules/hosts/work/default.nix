{ self, ... }:
{
  configurations.home-manager.work.module = {
    imports = [ self.modules.homeManager.cli ];
    home = {
      username = "thesse";
      homeDirectory = "/home/thesse";
      stateVersion = "25.11";
    };
  };
}
