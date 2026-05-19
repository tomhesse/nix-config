{
  flake.modules.nixos.smartctl-exporter = {
    services.prometheus = {
      exporters.smartctl = {
        enable = true;
        listenAddress = "127.0.0.1";
      };

      rules = [
        ''
          groups:
            - name: smartctl
              rules:
                - alert: SMARTDeviceTemperatureOverTripValue
                  expr: max_over_time(smartctl_device_temperature{temperature_type="current"} [10m]) >= on(device, instance) smartctl_device_temperature{temperature_type="drive_trip"}
                  for: 0m
                  labels:
                    severity: critical
                  annotations:
                    summary: "SMART device temperature over trip value (instance {{ $labels.instance }})"
                    description: "Device temperature over trip value on {{ $labels.instance }} drive {{ $labels.device }} ({{ $value }}°C)"

                - alert: SMARTDeviceTemperatureNearingTripValue
                  expr: max_over_time(smartctl_device_temperature{temperature_type="current"} [10m]) >= on(device, instance) (smartctl_device_temperature{temperature_type="drive_trip"} * .80)
                  for: 0m
                  labels:
                    severity: warning
                  annotations:
                    summary: "SMART device temperature nearing trip value (instance {{ $labels.instance }})"
                    description: "Device temperature at 80% of trip value on {{ $labels.instance }} drive {{ $labels.device }} ({{ $value }}°C)"

                - alert: SMARTStatus
                  expr: smartctl_device_smart_status != 1
                  for: 0m
                  labels:
                    severity: critical
                  annotations:
                    summary: "SMART status (instance {{ $labels.instance }})"
                    description: "Device has a SMART status failure on {{ $labels.instance }} drive {{ $labels.device }}"

                - alert: SMARTCriticalWarning
                  expr: smartctl_device_critical_warning > 0
                  for: 0m
                  labels:
                    severity: critical
                  annotations:
                    summary: "SMART critical warning (instance {{ $labels.instance }})"
                    description: "Disk controller has critical warning on {{ $labels.instance }} drive {{ $labels.device }}"

                - alert: SMARTMediaErrors
                  expr: increase(smartctl_device_media_errors[1h]) > 0
                  for: 0m
                  labels:
                    severity: critical
                  annotations:
                    summary: "SMART media errors (instance {{ $labels.instance }})"
                    description: "New media errors detected on {{ $labels.instance }} drive {{ $labels.device }}"

                - alert: SMARTWearoutIndicator
                  expr: smartctl_device_available_spare < smartctl_device_available_spare_threshold
                  for: 0m
                  labels:
                    severity: critical
                  annotations:
                    summary: "SMART Wearout Indicator (instance {{ $labels.instance }})"
                    description: "Device is wearing out on {{ $labels.instance }} drive {{ $labels.device }}"
        ''
      ];
    };
  };
}
