{
  services.hyprsunset = {
    enable = true;
    transitions = {
      morning = {
        calendar = "*-*-* 07:30:00";
        requests = [
          [
            "temperature"
            "5800"
          ]
        ];
      };
      noon = {
        calendar = "*-*-* 12:00:00";
        requests = [
          [
            "temperature"
            "6500"
          ]
        ];
      };
      evening = {
        calendar = "*-*-* 18:30:00";
        requests = [
          [
            "temperature"
            "5200"
          ]
        ];
      };
      late = {
        calendar = "*-*-* 21:30:00";
        requests = [
          [
            "temperature"
            "4100"
          ]
        ];
      };
      night = {
        calendar = "*-*-* 23:30:00";
        requests = [
          [
            "temperature"
            "3500"
          ]
        ];
      };
    };
  };
}
