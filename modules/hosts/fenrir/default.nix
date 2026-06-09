{ self, ... }:
{
  configurations.home-manager.fenrir.module = {
    imports = [ self.modules.homeManager.cli ];
    home = {
      username = "thesse";
      homeDirectory = "/home/thesse";
      stateVersion = "26.05";
    };
    programs.git = {
      signing.signByDefault = false;
      settings.user.email = "tom.hesse@atacama.de";
    };
    services.ssh-agent.enable = true;
  };
}
