{
  environment.persistence."/persist".directories = [
    "/var/db/sudo/lectured"
  ];

  security.sudo = {
    enable = true;
    execWheelOnly = true;
    wheelNeedsPassword = true;
  };
}
