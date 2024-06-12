# Monitoring the metal-stack

## Logging

Logs are being collected by
[Promtail](https://grafana.com/docs/loki/latest/send-data/promtail/) and pushed
to a [Loki](https://grafana.com/docs/loki/latest/) instance running in the
control plane. Loki is deployed in
[monolithic mode](https://grafana.com/docs/loki/latest/setup/install/helm/install-monolithic/)
and with storage type `'filesystem'`. You can find all logging related
configuration parameters for the control plane in the control plane's
[logging role](https://github.com/metal-stack/metal-roles/blob/master/control-plane/roles/logging/README.md).

In the partitions, Promtail is deployed inside a systemd-managed Docker
container. Configuration parameters can be found in the partition's
[promtail role](https://github.com/metal-stack/metal-roles/blob/master/partition/roles/promtail/README.md).
Which hosts Promtail collects from can be configured via the
`prometheus_promtail_targets` variable.

## Monitoring

For monitoring we deploy the
[kube-prometheus-stack](https://github.com/prometheus-operator/kube-prometheus)
and a [Thanos](https://thanos.io/tip/thanos/getting-started.md/) instance in the
control plane. Metrics for the control plane are supplied by

- `metal-metrics-exporter`
- `rethindb-exporter`
- `event-exporter`
- `gardener-metrics-exporter`

To query and visualize logs, metrics and alerts we deploy several grafana
dashboards to the control plane:

- `grafana-dashboard-alertmanager`
- `grafana-dashboard-machine-capacity`
- `grafana-dashboard-metal-api`
- `grafana-dashboard-rethinkdb`
- `grafana-dashboard-sonic-exporter`

and also some gardener related dashboards:

- `grafana-dashboard-gardener-overview`
- `grafana-dashboard-shoot-cluster`
- `grafana-dashboard-shoot-customizations`
- `grafana-dashboard-shoot-details`
- `grafana-dashboard-shoot-states`

The following `ServiceMonitors` are also deployed:

- `gardener-metrics-exporter`
- `ipam-db`
- `masterdata-api`
- `masterdata-db`
- `metal-api`
- `metal-db`
- `rethinkdb-exporter`
- `metal-metrics-exporter`

All monitoring related configuration parameters for the control plane can be
found in the control plane's
[monitoring role](https://github.com/metal-stack/metal-roles/blob/master/control-plane/roles/monitoring/README.md).

Partition metrics are supplied by

- `node-exporter`
- `blackbox-exporter`
- `ipmi-exporter`
- `sonic-exporter`
- `metal-core`
- `frr-exporter`

and scraped by Prometheus. For each of these exporters, the target hosts can be
defined by

- `prometheus_node_exporter_targets`
- `prometheus_blackbox_exporter_targets`
- `prometheus_frr_exporter_targets`
- `prometheus_sonic_exporter_targets`
- `prometheus_metal_core_targets`
- `prometheus_frr_exporter_targets`

## Alerting
