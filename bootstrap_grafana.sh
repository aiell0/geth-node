#!/bin/bash
KEY_NAME=$(echo $RANDOM)
GRAFANA_WORKSPACE_ID=$(terraform output -raw grafana_workspace_id)
PRIVATE_GETH_NODE_IP=$(terraform output -raw private_ip)
GRAFANA_API_KEY=$(aws grafana create-workspace-api-key --key-name $KEY_NAME --key-role "ADMIN" --seconds-to-live 5 --workspace-id $GRAFANA_WORKSPACE_ID --query 'key' --output text)

echo "creating datasource..."
curl -v -X POST https://$GRAFANA_WORKSPACE_ID.grafana-workspace.us-east-1.amazonaws.com/api/datasources -H 'Accept: application/json' -H 'Content-Type: application/json' -H "Authorization: Bearer $GRAFANA_API_KEY" -d '{"name": "geth-prometheus", "type": "prometheus", "url": "http://'${PRIVATE_GETH_NODE_IP}':9090", "access": "proxy", "basicAuth": false}'

DATASOURCE_ID=$(curl https://$GRAFANA_WORKSPACE_ID.grafana-workspace.us-east-1.amazonaws.com/api/datasources/id/geth-prometheus -H 'Accept: application/json' -H 'Content-Type: application/json' -H "Authorization: Bearer $GRAFANA_API_KEY" | jq .id)

aws grafana delete-workspace-api-key --key-name $KEY_NAME --workspace-id $GRAFANA_WORKSPACE_ID
