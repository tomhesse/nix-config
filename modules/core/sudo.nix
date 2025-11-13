{
  security.sudo = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
  };

  environment.persistence."/persist".directories = [
    "/var/db/sudo/lectured"
  ];
}
