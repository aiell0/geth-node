#!/bin/bash
KEY_NAME=$(echo $RANDOM)
GRAFANA_WORKSPACE_ID=$1
PRIVATE_GETH_NODE_IP=$2
GRAFANA_API_KEY=$(aws grafana create-workspace-api-key --key-name $KEY_NAME --key-role "ADMIN" --seconds-to-live 15 --workspace-id $GRAFANA_WORKSPACE_ID --query 'key' --output text)

echo "creating datasource..."
curl -X POST https://$GRAFANA_WORKSPACE_ID.grafana-workspace.us-east-1.amazonaws.com/api/datasources -H 'Accept: application/json' -H 'Content-Type: application/json' -H "Authorization: Bearer $GRAFANA_API_KEY" -d '{"name": "geth-prometheus", "type": "prometheus", "url": "http://'${PRIVATE_GETH_NODE_IP}':9090", "access": "proxy", "basicAuth": false}'

DATASOURCE_UID=$(curl https://$GRAFANA_WORKSPACE_ID.grafana-workspace.us-east-1.amazonaws.com/api/datasources/name/geth-prometheus -H 'Accept: application/json' -H 'Content-Type: application/json' -H "Authorization: Bearer $GRAFANA_API_KEY" | jq --raw-output .uid)

sed -e "s/\"uid\": \"\${DS_VICTORIAMETRICS}\"/\"uid\": \"$DATASOURCE_UID\"/g" grafana_dashboard_presed.json > grafana_dashboard.json

echo "creating dashboard..."
curl -X POST https://$GRAFANA_WORKSPACE_ID.grafana-workspace.us-east-1.amazonaws.com/api/dashboards/db -H 'Accept: application/json' -H 'Content-Type: application/json' -H "Authorization: Bearer $GRAFANA_API_KEY" -d @grafana_dashboard.json

rm grafana_dashboard.json

aws grafana delete-workspace-api-key --key-name $KEY_NAME --workspace-id $GRAFANA_WORKSPACE_ID > /dev/null
