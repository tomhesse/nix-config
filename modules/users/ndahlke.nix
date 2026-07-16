{
  flake.modules.nixos.user-ndahlke = {
    users.users.ndahlke = {
      isSystemUser = true;
      group = "ndahlke";
    };
  };
}
