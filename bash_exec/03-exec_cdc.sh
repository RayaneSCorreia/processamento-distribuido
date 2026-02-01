#!/usr/bin/env bash
set -euo pipefail

echo "======================================================"
echo " 🔄 EXECUTANDO EVENTOS CDC "
echo "======================================================"

# Executa o SQL DENTRO do container postgres_source_cdc_strava
docker exec -i postgres_source_cdc_strava \
psql -h localhost -p 5432 -U postgres -d strava_source -f ./scripts/cdc_create_events_change.sql

echo -e "✅ Eventos CDC aplicados com sucesso!"
echo "======================================================"
echo "📊 Mostrando contagem após alterações:"

docker exec -i postgres_source_cdc_strava \
psql -h localhost -p 5432 -U postgres -d strava_source \
    -c "SELECT COUNT(*) AS total_atual FROM strava_activities;"
