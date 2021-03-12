#!/bin/bash -eux

# Bootstrap script

set -euo pipefail

if [ -e /root/ran_customization ]; then
    exit
else
    
    (echo >/dev/tcp/localhost/3000) &>/dev/null && grafana_active="active" || grafana_active="inactive"
    while [ "active" !=  ${grafana_active} ]
    do 
        sleep 2
        (echo >/dev/tcp/localhost/3000) &>/dev/null && grafana_active="active" || grafana_active="inactive";
    done

    curl -X POST \
    -d '{"name":"Prometheus","type":"prometheus","typeLogoUrl":"public/app/plugins/datasource/prometheus/img/prometheus_logo.svg","access":"proxy","url":"http://localhost:9090","basicAuth":false,"isDefault":true}' \
    -H 'Content-Type: application/json; Accept: application/json' \
    -u admin:default \
    http://localhost:3000/api/datasources

    #replace some vars in the json
    #sed -i "s/\${DS_PROMETHEUS}/Prometheus/g" /root/files/node-exporter-full_rev22.json

    echo '{"dashboard": '$(cat /root/files/node-exporter-full_rev22.json)'}' | \
    curl -X POST \
    --data-binary @- \
    -H 'Content-Type: application/json; Accept: application/json' \
    -u admin:default \
    http://localhost:3000/api/dashboards/db

    # Ensure we don't run customization again
    touch /root/ran_customization
fi