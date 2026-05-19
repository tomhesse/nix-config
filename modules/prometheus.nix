{
  flake.modules.nixos.prometheus = {
    services = {
      prometheus = {
        enable = true;
        listenAddress = "127.0.0.1";
        webExternalUrl = "https://prometheus.shrimphouse.xyz";

        retentionTime = "30d";

        alertmanagers = [
          {
            static_configs = [
              { targets = [ "127.0.0.1:9093" ]; }
            ];
          }
        ];

        rules = [
          ''
            groups:
              - name: prometheus
                rules:
                  - alert: PrometheusJobMissing
                    expr: absent(up{job="prometheus"})
                    for: 0m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Prometheus job missing (instance {{ $labels.instance }})"
                      description: "A Prometheus job has disappeared\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusTargetMissing
                    expr: up == 0 unless on(job) (sum by (job) (up) == 0)
                    for: 1m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Prometheus target missing (instance {{ $labels.instance }})"
                      description: "A Prometheus target has disappeared. An exporter might be crashed.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusAllTargetsMissing
                    expr: sum by (job) (up) == 0
                    for: 1m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Prometheus all targets missing (instance {{ $labels.instance }})"
                      description: "A Prometheus job does not have living target anymore.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusConfigurationReloadFailure
                    expr: prometheus_config_last_reload_successful != 1
                    for: 0m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Prometheus configuration reload failure (instance {{ $labels.instance }})"
                      description: "Prometheus configuration reload error\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusTooManyRestarts
                    expr: changes(process_start_time_seconds{job=~"prometheus|pushgateway|alertmanager"}[15m]) > 2
                    for: 0m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Prometheus too many restarts (instance {{ $labels.instance }})"
                      description: "Prometheus has restarted more than twice in the last 15 minutes. It might be crashlooping.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusAlertmanagerJobMissing
                    expr: absent(up{job="alertmanager"})
                    for: 0m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Prometheus AlertManager job missing (instance {{ $labels.instance }})"
                      description: "A Prometheus AlertManager job has disappeared\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusAlertmanagerConfigurationReloadFailure
                    expr: alertmanager_config_last_reload_successful != 1
                    for: 0m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Prometheus AlertManager configuration reload failure (instance {{ $labels.instance }})"
                      description: "AlertManager configuration reload error\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusNotConnectedToAlertmanager
                    expr: prometheus_notifications_alertmanagers_discovered < 1
                    for: 0m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Prometheus not connected to alertmanager (instance {{ $labels.instance }})"
                      description: "Prometheus cannot connect the alertmanager\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusRuleEvaluationFailures
                    expr: increase(prometheus_rule_evaluation_failures_total[3m]) > 0
                    for: 0m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Prometheus rule evaluation failures (instance {{ $labels.instance }})"
                      description: "Prometheus encountered {{ $value }} rule evaluation failures, leading to potentially ignored alerts.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusTemplateTextExpansionFailures
                    expr: increase(prometheus_template_text_expansion_failures_total[3m]) > 0
                    for: 0m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Prometheus template text expansion failures (instance {{ $labels.instance }})"
                      description: "Prometheus encountered {{ $value }} template text expansion failures\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusRuleEvaluationSlow
                    expr: prometheus_rule_group_last_duration_seconds > prometheus_rule_group_interval_seconds
                    for: 5m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Prometheus rule evaluation slow (instance {{ $labels.instance }})"
                      description: "Prometheus rule evaluation took more time than the scheduled interval. It indicates a slower storage backend access or too complex query.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusNotificationsBacklog
                    expr: min_over_time(prometheus_notifications_queue_length[10m]) > 0
                    for: 0m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Prometheus notifications backlog (instance {{ $labels.instance }})"
                      description: "The Prometheus notification queue has not been empty for 10 minutes\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusAlertmanagerNotificationFailing
                    expr: rate(alertmanager_notifications_failed_total[3m]) > 0.05
                    for: 0m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Prometheus AlertManager notification failing (instance {{ $labels.instance }})"
                      description: "Alertmanager is failing sending notifications ({{ $value }} notifications/s)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusTargetEmpty
                    expr: prometheus_sd_discovered_targets == 0
                    for: 0m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Prometheus target empty (instance {{ $labels.instance }})"
                      description: "Prometheus has no target in service discovery\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusTargetScrapingSlow
                    expr: prometheus_target_interval_length_seconds{quantile="0.9"} / on (interval, instance, job) prometheus_target_interval_length_seconds{quantile="0.5"} > 1.05
                    for: 5m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Prometheus target scraping slow (instance {{ $labels.instance }})"
                      description: "Prometheus is scraping exporters slowly since it exceeded the requested interval time. Your Prometheus server is under-provisioned.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusLargeScrape
                    expr: increase(prometheus_target_scrapes_exceeded_sample_limit_total[10m]) > 10
                    for: 5m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Prometheus large scrape (instance {{ $labels.instance }})"
                      description: "Prometheus has many scrapes that exceed the sample limit ({{ $value }} scrapes)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusTargetScrapeDuplicate
                    expr: increase(prometheus_target_scrapes_sample_duplicate_timestamp_total[5m]) > 3
                    for: 0m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Prometheus target scrape duplicate (instance {{ $labels.instance }})"
                      description: "Prometheus has many samples rejected due to duplicate timestamps but different values ({{ $value }} samples)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusTsdbCheckpointCreationFailures
                    expr: increase(prometheus_tsdb_checkpoint_creations_failed_total[1m]) > 0
                    for: 0m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Prometheus TSDB checkpoint creation failures (instance {{ $labels.instance }})"
                      description: "Prometheus encountered {{ $value }} checkpoint creation failures\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusTsdbCheckpointDeletionFailures
                    expr: increase(prometheus_tsdb_checkpoint_deletions_failed_total[1m]) > 0
                    for: 0m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Prometheus TSDB checkpoint deletion failures (instance {{ $labels.instance }})"
                      description: "Prometheus encountered {{ $value }} checkpoint deletion failures\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusTsdbCompactionsFailed
                    expr: increase(prometheus_tsdb_compactions_failed_total[1m]) > 0
                    for: 0m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Prometheus TSDB compactions failed (instance {{ $labels.instance }})"
                      description: "Prometheus encountered {{ $value }} TSDB compactions failures\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusTsdbHeadTruncationsFailed
                    expr: increase(prometheus_tsdb_head_truncations_failed_total[1m]) > 0
                    for: 0m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Prometheus TSDB head truncations failed (instance {{ $labels.instance }})"
                      description: "Prometheus encountered {{ $value }} TSDB head truncation failures\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusTsdbReloadFailures
                    expr: increase(prometheus_tsdb_reloads_failures_total[1m]) > 0
                    for: 0m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Prometheus TSDB reload failures (instance {{ $labels.instance }})"
                      description: "Prometheus encountered {{ $value }} TSDB reload failures\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusTsdbWalCorruptions
                    expr: increase(prometheus_tsdb_wal_corruptions_total[1m]) > 0
                    for: 0m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Prometheus TSDB WAL corruptions (instance {{ $labels.instance }})"
                      description: "Prometheus encountered {{ $value }} TSDB WAL corruptions\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusTsdbWalTruncationsFailed
                    expr: increase(prometheus_tsdb_wal_truncations_failed_total[1m]) > 0
                    for: 0m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Prometheus TSDB WAL truncations failed (instance {{ $labels.instance }})"
                      description: "Prometheus encountered {{ $value }} TSDB WAL truncation failures\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: PrometheusTimeseriesCardinality
                    expr: label_replace(count by(__name__) ({__name__=~".+"}), "name", "$1", "__name__", "(.+)") > 10000
                    for: 0m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Prometheus timeseries cardinality (instance {{ $labels.instance }})"
                      description: "The \"{{ $labels.name }}\" timeseries cardinality is getting very high: {{ $value }}\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

              - name: node-exporter
                rules:
                  - alert: HostOutOfMemory
                    expr: (node_memory_MemAvailable_bytes / node_memory_MemTotal_bytes < .05)
                    for: 2m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host out of memory (instance {{ $labels.instance }})"
                      description: "Node memory is filling up (< 5% left)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostMemoryUnderMemoryPressure
                    expr: (deriv(node_vmstat_pgmajfault[5m]) > 1000)
                    for: 0m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host memory under memory pressure (instance {{ $labels.instance }})"
                      description: "The node is under heavy memory pressure. High rate of major page faults ({{ $value }}/s).\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostUnusualNetworkThroughputIn
                    expr: ((rate(node_network_receive_bytes_total[5m]) / node_network_speed_bytes) > .80) and node_network_speed_bytes > 0
                    for: 0m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host unusual network throughput in (instance {{ $labels.instance }})"
                      description: "Host receive bandwidth is high (>80%).\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostUnusualNetworkThroughputOut
                    expr: ((rate(node_network_transmit_bytes_total[5m]) / node_network_speed_bytes) > .80) and node_network_speed_bytes > 0
                    for: 0m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host unusual network throughput out (instance {{ $labels.instance }})"
                      description: "Host transmit bandwidth is high (>80%)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostDiskIoUtilizationHigh
                    expr: (rate(node_disk_io_time_seconds_total[5m]) > .80)
                    for: 0m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host disk IO utilization high (instance {{ $labels.instance }})"
                      description: "Disk utilization is high (> 80%)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostOutOfDiskSpace
                    expr: (node_filesystem_avail_bytes{fstype!~"^(fuse.*|tmpfs|cifs|nfs)"} / node_filesystem_size_bytes < .10 and on (instance, device, mountpoint) node_filesystem_readonly == 0)
                    for: 2m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Host out of disk space (instance {{ $labels.instance }})"
                      description: "Disk is almost full (< 10% left)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostDiskMayFillIn24Hours
                    expr: predict_linear(node_filesystem_avail_bytes{fstype!~"^(fuse.*|tmpfs|cifs|nfs)"}[3h], 86400) <= 0 and node_filesystem_avail_bytes > 0
                    for: 2m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host disk may fill in 24 hours (instance {{ $labels.instance }})"
                      description: "Filesystem will likely run out of space within the next 24 hours.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostOutOfInodes
                    expr: (node_filesystem_files_free / node_filesystem_files < .10 and ON (instance, device, mountpoint) node_filesystem_readonly == 0) and node_filesystem_files > 0
                    for: 2m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Host out of inodes (instance {{ $labels.instance }})"
                      description: "Disk is almost running out of available inodes (< 10% left)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostFilesystemDeviceError
                    expr: node_filesystem_device_error{fstype!~"^(fuse.*|tmpfs|cifs|nfs)", mountpoint!~"/home/.*"} == 1
                    for: 2m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Host filesystem device error (instance {{ $labels.instance }})"
                      description: "Error stat-ing the {{ $labels.mountpoint }} filesystem\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostInodesMayFillIn24Hours
                    expr: predict_linear(node_filesystem_files_free{fstype!~"^(fuse.*|tmpfs|cifs|nfs)"}[1h], 86400) <= 0 and node_filesystem_files_free > 0
                    for: 2m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host inodes may fill in 24 hours (instance {{ $labels.instance }})"
                      description: "Filesystem will likely run out of inodes within the next 24 hours at current write rate\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostUnusualDiskReadLatency
                    expr: (rate(node_disk_read_time_seconds_total[1m]) / rate(node_disk_reads_completed_total[1m]) > 0.1 and rate(node_disk_reads_completed_total[1m]) > 0)
                    for: 2m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host unusual disk read latency (instance {{ $labels.instance }})"
                      description: "Disk latency is growing (read operations > 100ms)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostUnusualDiskWriteLatency
                    expr: (rate(node_disk_write_time_seconds_total[1m]) / rate(node_disk_writes_completed_total[1m]) > 0.1 and rate(node_disk_writes_completed_total[1m]) > 0)
                    for: 2m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host unusual disk write latency (instance {{ $labels.instance }})"
                      description: "Disk latency is growing (write operations > 100ms)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostHighCpuLoad
                    expr: 1 - (avg without (cpu) (rate(node_cpu_seconds_total{mode="idle"}[5m]))) > .80
                    for: 10m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host high CPU load (instance {{ $labels.instance }})"
                      description: "CPU load is > 80%\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostCpuHighIowait
                    expr: avg without (cpu) (rate(node_cpu_seconds_total{mode="iowait"}[5m])) > .10
                    for: 0m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host CPU high iowait (instance {{ $labels.instance }})"
                      description: "CPU iowait > 10%. Your CPU is idling waiting for storage to respond.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostSwapIsFillingUp
                    expr: ((1 - (node_memory_SwapFree_bytes / node_memory_SwapTotal_bytes)) * 100 > 80) and node_memory_SwapTotal_bytes > 0
                    for: 2m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host swap is filling up (instance {{ $labels.instance }})"
                      description: "Swap is filling up (>80%)\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostSystemdServiceCrashed
                    expr: (node_systemd_unit_state{state="failed"} == 1)
                    for: 0m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host systemd service crashed (instance {{ $labels.instance }})"
                      description: "systemd service {{ $labels.name }} crashed\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostPhysicalComponentTooHot
                    expr: node_hwmon_temp_celsius > node_hwmon_temp_max_celsius
                    for: 5m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host physical component too hot (instance {{ $labels.instance }})"
                      description: "Physical hardware component too hot\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostNodeOvertemperatureAlarm
                    expr: ((node_hwmon_temp_crit_alarm_celsius == 1) or (node_hwmon_temp_alarm == 1))
                    for: 0m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Host node overtemperature alarm (instance {{ $labels.instance }})"
                      description: "Physical node temperature alarm triggered\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostSoftwareRaidInsufficientDrives
                    expr: ((node_md_disks_required - ignoring(state) node_md_disks{state="active"}) > 0)
                    for: 0m
                    labels:
                      severity: critical
                    annotations:
                      summary: "Host software RAID insufficient drives (instance {{ $labels.instance }})"
                      description: "MD RAID array {{ $labels.device }} on {{ $labels.instance }} has insufficient drives remaining.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostSoftwareRaidDiskFailure
                    expr: (node_md_disks{state="failed"} > 0)
                    for: 2m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host software RAID disk failure (instance {{ $labels.instance }})"
                      description: "MD RAID array {{ $labels.device }} on {{ $labels.instance }} needs attention.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostOomKillDetected
                    expr: (delta(node_vmstat_oom_kill[30m]) > 0)
                    for: 0m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host OOM kill detected (instance {{ $labels.instance }})"
                      description: "OOM kill detected\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostEdacCorrectableErrorsDetected
                    expr: (increase(node_edac_correctable_errors_total[1m]) > 0)
                    for: 0m
                    labels:
                      severity: info
                    annotations:
                      summary: "Host EDAC Correctable Errors detected (instance {{ $labels.instance }})"
                      description: "Host {{ $labels.instance }} has had {{ printf \"%.0f\" $value }} correctable memory errors reported by EDAC in the last 1 minute.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostEdacUncorrectableErrorsDetected
                    expr: (node_edac_uncorrectable_errors_total > 0)
                    for: 0m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host EDAC Uncorrectable Errors detected (instance {{ $labels.instance }})"
                      description: "Host {{ $labels.instance }} has had {{ printf \"%.0f\" $value }} uncorrectable memory errors reported by EDAC.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostNetworkReceiveErrors
                    expr: (rate(node_network_receive_errs_total[2m]) / rate(node_network_receive_packets_total[2m]) > 0.01) and rate(node_network_receive_packets_total[2m]) > 0
                    for: 2m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host Network Receive Errors (instance {{ $labels.instance }})"
                      description: "Host {{ $labels.instance }} interface {{ $labels.device }} has encountered {{ printf \"%.0f\" $value }} receive errors in the last two minutes.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostNetworkTransmitErrors
                    expr: (rate(node_network_transmit_errs_total[2m]) / rate(node_network_transmit_packets_total[2m]) > 0.01) and rate(node_network_transmit_packets_total[2m]) > 0
                    for: 2m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host Network Transmit Errors (instance {{ $labels.instance }})"
                      description: "Host {{ $labels.instance }} interface {{ $labels.device }} has encountered {{ printf \"%.0f\" $value }} transmit errors in the last two minutes.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostConntrackLimit
                    expr: (node_nf_conntrack_entries / node_nf_conntrack_entries_limit > 0.8) and node_nf_conntrack_entries_limit > 0
                    for: 5m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host conntrack limit (instance {{ $labels.instance }})"
                      description: "The number of conntrack is approaching limit\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostClockSkew
                    expr: ((node_timex_offset_seconds > 0.05 and deriv(node_timex_offset_seconds[5m]) >= 0) or (node_timex_offset_seconds < -0.05 and deriv(node_timex_offset_seconds[5m]) <= 0))
                    for: 10m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host clock skew (instance {{ $labels.instance }})"
                      description: "Clock skew detected. Clock is out of sync. Ensure NTP is configured correctly on this host.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

                  - alert: HostClockNotSynchronising
                    expr: (min_over_time(node_timex_sync_status[1m]) == 0 and node_timex_maxerror_seconds >= 16)
                    for: 2m
                    labels:
                      severity: warning
                    annotations:
                      summary: "Host clock not synchronising (instance {{ $labels.instance }})"
                      description: "Clock not synchronising. Ensure NTP is configured on this host.\n  VALUE = {{ $value }}\n  LABELS = {{ $labels }}"

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

        scrapeConfigs = [
          {
            job_name = "node";
            static_configs = [
              { targets = [ "127.0.0.1:9100" ]; }
            ];
          }
          {
            job_name = "prometheus";
            static_configs = [
              { targets = [ "127.0.0.1:9090" ]; }
            ];
          }
          {
            job_name = "alertmanager";
            static_configs = [
              { targets = [ "127.0.0.1:9093" ]; }
            ];
          }
          {
            job_name = "bazarr";
            static_configs = [
              { targets = [ "127.0.0.1:9711" ]; }
            ];
          }
          {
            job_name = "grafana";
            static_configs = [
              { targets = [ "127.0.0.1:3001" ]; }
            ];
          }
          {
            job_name = "prowlarr";
            static_configs = [
              { targets = [ "127.0.0.1:9710" ]; }
            ];
          }
          {
            job_name = "radarr";
            static_configs = [
              { targets = [ "127.0.0.1:9708" ]; }
            ];
          }
          {
            job_name = "sabnzbd";
            static_configs = [
              { targets = [ "127.0.0.1:9387" ]; }
            ];
          }
          {
            job_name = "smartctl";
            static_configs = [
              { targets = [ "127.0.0.1:9633" ]; }
            ];
          }
          {
            job_name = "sonarr";
            static_configs = [
              { targets = [ "127.0.0.1:9709" ]; }
            ];
          }
        ];
      };

      oauth2-proxy.nginx.virtualHosts."prometheus.shrimphouse.xyz".allowed_groups = [
        "monitoring_users@shrimphouse.xyz"
      ];

      nginx.virtualHosts."prometheus.shrimphouse.xyz" = {
        useACMEHost = "prometheus.shrimphouse.xyz";
        forceSSL = true;

        locations."/".proxyPass = "http://127.0.0.1:9090";
      };
    };

    security.acme.certs."prometheus.shrimphouse.xyz".group = "nginx";
  };
}
