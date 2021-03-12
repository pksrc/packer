#!/bin/bash -eux

set -euo pipefail

# Download Prometheus

echo -e "\e[92mDownloading Prometheus v2.25.0..." > /dev/console
wget https://github.com/prometheus/prometheus/releases/download/v2.25.0/prometheus-2.25.0.linux-amd64.tar.gz

echo -e "\e[92mDownloading Exporter - BlackBox Exporter v0.18.0..." > /dev/console
wget https://github.com/prometheus/blackbox_exporter/releases/download/v0.18.0/blackbox_exporter-0.18.0.linux-amd64.tar.gz

echo -e "\e[92mDownloading Exporter - Node Exporter v1.1.2..." > /dev/console
wget https://github.com/prometheus/node_exporter/releases/download/v1.1.2/node_exporter-1.1.2.linux-amd64.tar.gz

echo -e "\e[92mDownloading Exporter - Alert Manager v0.21.0..." > /dev/console
wget https://github.com/prometheus/alertmanager/releases/download/v0.21.0/alertmanager-0.21.0.linux-amd64.tar.gz

echo -e "\e[92mExtracting Packages..." > /dev/console
tar -zxvf prometheus-2.25.0.linux-amd64.tar.gz 
tar -zxvf alertmanager-0.21.0.linux-amd64.tar.gz
tar -zxvf node_exporter-1.1.2.linux-amd64.tar.gz
tar -zxvf blackbox_exporter-0.18.0.linux-amd64.tar.gz

##################################
###      Prometheus Setup      ###
##################################

echo -e "\e[92mSetting up Prometheus..." > /dev/console
useradd --user-group --no-create-home --shell /usr/sbin/nologin prometheus
#userdel -r prometheus

mkdir /etc/prometheus
mkdir /var/lib/prometheus

chown prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /var/lib/prometheus

cp prometheus-2.25.0.linux-amd64/prometheus /usr/local/bin/
cp prometheus-2.25.0.linux-amd64/promtool /usr/local/bin/

chown prometheus:prometheus /usr/local/bin/prometheus
chown prometheus:prometheus /usr/local/bin/promtool

cp -r prometheus-2.25.0.linux-amd64/consoles /etc/prometheus
cp -r prometheus-2.25.0.linux-amd64/console_libraries /etc/prometheus

chown -R prometheus:prometheus /etc/prometheus/consoles
chown -R prometheus:prometheus /etc/prometheus/console_libraries

cat > /etc/prometheus/prometheus.yml << __PROMETHEUS_YAML__
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9090', 'localhost:9115']
  - job_name: 'node_exporter'
    scrape_interval: 5s
    static_configs:
      - targets: ['localhost:9100']
  - job_name: 'blackbox'
    metrics_path: /probe
    params:
      module: [http_uag] 
    static_configs:
      - targets:
        - https://uag.lab.pdotk.com:9443    # Target to probe with https.
    relabel_configs:
      - source_labels: [__address__]
        target_label: __param_target
      - source_labels: [__param_target]
        target_label: instance
      - target_label: __address__
        replacement: 127.0.0.1:9115  # The blackbox exporter's real hostname:port.
  - job_name: 'uag'
    metrics_path: /metric
    honor_labels: true
    scrape_interval: 1m
    scrape_timeout: 10s
    scheme: http
    dns_sd_configs:
    - names:
      - localhost
      type: 'A'
      port: 8000
__PROMETHEUS_YAML__

chown prometheus:prometheus /etc/prometheus/prometheus.yml

cat > /etc/systemd/system/prometheus.service << __PROMETHEUS_SVC__
[Unit]
  Description=Prometheus Monitoring
  Wants=network-online.target
  After=network-online.target

[Service]
  User=prometheus
  Group=prometheus
  Type=simple
  ExecStart=/usr/local/bin/prometheus \
  --config.file /etc/prometheus/prometheus.yml \
  --storage.tsdb.path /var/lib/prometheus/ \
  --web.console.templates=/etc/prometheus/consoles \
  --web.console.libraries=/etc/prometheus/console_libraries

[Install]
  WantedBy=multi-user.target
__PROMETHEUS_SVC__

systemctl start prometheus
systemctl enable prometheus

##################################
###  Prometheus NODE Exporter  ###
##################################

echo -e "\e[92mSetting up Node Exporter..." > /dev/console
useradd --user-group --no-create-home --shell /bin/false node_exporter
#userdel -r node_exporter

cp node_exporter-1.1.2.linux-amd64/node_exporter /usr/local/bin
chown node_exporter:node_exporter /usr/local/bin/node_exporter

echo -e "\e[92mConfiguring Static IP Address ..." > /dev/console

cat > /etc/systemd/system/node_exporter.service << __NODE_SVC__
[Unit]
Description=Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
User=node_exporter
Group=node_exporter
Type=simple
ExecStart=/usr/local/bin/node_exporter

[Install]
WantedBy=multi-user.target
__NODE_SVC__

systemctl start node_exporter
systemctl enable node_exporter
