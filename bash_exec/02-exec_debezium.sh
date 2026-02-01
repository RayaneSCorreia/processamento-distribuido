#!/usr/bin/env sh
set -ex

# Se estiver rodando dentro do Docker, usa DNS do serviço
if [ -f /.dockerenv ]; then
  CONNECT_URL="http://connect_cdc_strava:8083"
else
  CONNECT_URL="http://localhost:8083"
fi

CONNECTOR_JSON="/app/connectors/source-postgres-strava.json"

# Se estiver no host, ajusta o caminho
if [ ! -f "$CONNECTOR_JSON" ]; then
  CONNECTOR_JSON="./connectors/source-postgres-strava.json"
fi

echo "Kafka Connect URL: $CONNECT_URL"
echo "Connector JSON: $CONNECTOR_JSON"

echo "Aguardando Kafka Connect..."
until curl -fsS "${CONNECT_URL}/" > /dev/null; do
  sleep 2
done

echo "Criando conector..."
curl -v -X POST "${CONNECT_URL}/connectors" \
  -H "Content-Type: application/json" \
  -d @"${CONNECTOR_JSON}"

echo "Fim"
