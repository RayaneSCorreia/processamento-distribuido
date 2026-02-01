#!/usr/bin/env bash
set -euo pipefail

echo "======================================================"
echo "🧱 Criando tabelas no Postgres (se não existirem)"
echo "======================================================"

docker compose exec -T postgres_dest_cdc_strava psql -U postgres -d strava_dest -v ON_ERROR_STOP=1 -c "
CREATE TABLE IF NOT EXISTS public.silver_strava_activities (
    activity_id BIGINT PRIMARY KEY,
    activity_name TEXT,
    activity_sport_type TEXT,
    activity_distance DOUBLE PRECISION,
    activity_moving_time INTEGER,
    activity_start_date TIMESTAMP,
    activity_updated_at TIMESTAMP,
    activity_device_name TEXT,
    activity_entry_source TEXT,
    cdc_op TEXT,
    cdc_ts_ms BIGINT,
    ingestion_ts TIMESTAMP
);
"

docker compose exec -T postgres_dest_cdc_strava psql -U postgres -d strava_dest -v ON_ERROR_STOP=1 -c "
CREATE TABLE IF NOT EXISTS public.silver_strava_activities_stage (
    activity_id BIGINT,
    activity_name TEXT,
    activity_sport_type TEXT,
    activity_distance DOUBLE PRECISION,
    activity_moving_time INTEGER,
    activity_start_date TIMESTAMP,
    activity_updated_at TIMESTAMP,
    activity_device_name TEXT,
    activity_entry_source TEXT,
    cdc_op TEXT,
    cdc_ts_ms BIGINT,
    ingestion_ts TIMESTAMP
);
"

echo "======================================================"
echo "🚀 Executando Spark job (Kafka -> Postgres)"
echo "======================================================"

docker compose run --rm -T \
  --entrypoint /opt/spark/bin/spark-submit \
  spark_cdc_strava \
  --master "local[*]" \
  --conf "spark.jars.ivy=/tmp/ivy" \
  --packages "org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.1,org.postgresql:postgresql:42.7.3" \
  /opt/spark-apps/kafka_to_postgres.py

echo "======================================================"
echo "✅ Spark job finalizado"
echo "======================================================"

echo "======================================================"
echo "🧬 UPSERT"
echo "======================================================"

docker compose exec -T postgres_dest_cdc_strava psql -U postgres -d strava_dest -v ON_ERROR_STOP=1 -c \
"
WITH dedup AS (
SELECT DISTINCT ON (activity_id)
    activity_id, activity_name, activity_sport_type, activity_distance,
    activity_moving_time, activity_start_date, activity_updated_at,
    activity_device_name, activity_entry_source,
    cdc_op, cdc_ts_ms, ingestion_ts
FROM public.silver_strava_activities_stage
WHERE activity_id IS NOT NULL
ORDER BY activity_id, cdc_ts_ms DESC NULLS LAST, ingestion_ts DESC
)
INSERT INTO public.silver_strava_activities (
    activity_id, activity_name, activity_sport_type, activity_distance,
    activity_moving_time, activity_start_date, activity_updated_at,
    activity_device_name, activity_entry_source,
    cdc_op, cdc_ts_ms, ingestion_ts
)
SELECT
    activity_id, activity_name, activity_sport_type, activity_distance,
    activity_moving_time, activity_start_date, activity_updated_at,
    activity_device_name, activity_entry_source,
    cdc_op, cdc_ts_ms, ingestion_ts
FROM dedup
ON CONFLICT (activity_id) DO UPDATE SET
    activity_name         = EXCLUDED.activity_name,
    activity_sport_type   = EXCLUDED.activity_sport_type,
    activity_distance     = EXCLUDED.activity_distance,
    activity_moving_time  = EXCLUDED.activity_moving_time,
    activity_start_date   = EXCLUDED.activity_start_date,
    activity_updated_at   = EXCLUDED.activity_updated_at,
    activity_device_name  = EXCLUDED.activity_device_name,
    activity_entry_source = EXCLUDED.activity_entry_source,
    cdc_op                = EXCLUDED.cdc_op,
    cdc_ts_ms             = EXCLUDED.cdc_ts_ms,
    ingestion_ts          = EXCLUDED.ingestion_ts;

TRUNCATE TABLE public.silver_strava_activities_stage;
"
