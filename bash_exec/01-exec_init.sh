#!/usr/bin/env bash
set -euo pipefail

echo "=============================================================="
echo " EXECUTANDO CARGA INICIAL"
echo "=============================================================="

# Executa o SQL DENTRO do container postgres_source_cdc_strava
docker exec -i postgres_source_cdc_strava \
    psql -U postgres -d strava_source \
    -f /scripts/input_strava_init.sql
    
echo "=============================================================="
echo " ✅ Carga inicial concluída!"
echo "=============================================================="

echo "📊 Contagem após init:"
docker exec -i postgres_source_cdc_strava \
    psql -U postgres -d strava_source \
    -c "SELECT COUNT(*) AS total_registros FROM strava_activities;"
