#!/bin/bash -eux

set -euo pipefail


##################################
###     Installing Grafana     ###
##################################

wget https://dl.grafana.com/oss/release/grafana-7.4.3.linux-amd64.tar.gz
tar -zxvf grafana-7.4.3.linux-amd64.tar.gz

echo -e "\e[92mSetting up Node Exporter..." > /dev/console
useradd --user-group --home-dir /usr/share/grafana --shell /bin/false grafana

#mkdir /var/log/grafana
#mkdir -p /var/lib/grafana/plugins
mkdir -p /etc/grafana/provisioning

#chown grafana:grafana /var/log/grafana
#chown -R grafana:grafana /var/lib/grafana
chown -R grafana:grafana /etc/grafana

cp grafana-7.4.3/bin/grafana-server /usr/local/bin
chown grafana:grafana /usr/local/bin/grafana-server

cp -R grafana-7.4.3/ /usr/share/grafana/
chown -R grafana:grafana /usr/share/grafana/

cat > /etc/default/grafana-vars << __GRAFANA_VARS__
GRAFANA_USER=grafana

GRAFANA_GROUP=grafana

GRAFANA_HOME=/usr/share/grafana

LOG_DIR=/var/log/grafana

DATA_DIR=/var/lib/grafana

MAX_OPEN_FILES=10000

CONF_DIR=/etc/grafana

CONF_FILE=/etc/grafana/grafana.ini

RESTART_ON_UPGRADE=true

PLUGINS_DIR=/var/lib/grafana/plugins

PROVISIONING_CFG_DIR=/etc/grafana/provisioning

# Only used on systemd systems
PID_FILE_DIR=/var/run/grafana
__GRAFANA_VARS__

chown grafana:grafana /etc/default/grafana-vars

ls 

cp /root/files/defaults.ini /usr/share/grafana/conf/defaults.ini

cat > /etc/systemd/system/grafana.service << '__GRAFANA_SVC__'
[Unit]
Description=Grafana instance
Documentation=http://docs.grafana.org
Wants=network-online.target
After=network-online.target

[Service]
User=grafana
Group=grafana
Type=simple
WorkingDirectory=/usr/share/grafana
RuntimeDirectory=grafana
RuntimeDirectoryMode=0750
ExecStart=/usr/share/grafana/bin/grafana-server --config=/usr/share/grafana/conf/defaults.ini

LimitNOFILE=10000
TimeoutStopSec=20
UMask=0027

[Install]
WantedBy=multi-user.target
__GRAFANA_SVC__

systemctl start grafana
systemctl enable grafana
