#!/usr/bin/env bash
set -euo pipefail

echo "======================================================"
echo "🚀 Executando Spark job (container on-demand)"
echo "======================================================"

docker compose run --rm -T spark_cdc_strava '
  /opt/spark/bin/spark-submit \
    --master local[*] \
    --conf spark.jars.ivy=/tmp/ivy \
    --packages "org.apache.spark:spark-sql-kafka-0-10_2.12:3.5.1,org.apache.hadoop:hadoop-aws:3.3.4,com.amazonaws:aws-java-sdk-bundle:1.12.262" \
    --conf "spark.hadoop.fs.s3a.endpoint=http://minio:9000" \
    --conf "spark.hadoop.fs.s3a.access.key=minio_cdc_strava" \
    --conf "spark.hadoop.fs.s3a.secret.key=minio_cdc_strava" \
    --conf "spark.hadoop.fs.s3a.path.style.access=true" \
    --conf "spark.hadoop.fs.s3a.connection.ssl.enabled=false" \
    --conf "spark.hadoop.fs.s3a.impl=org.apache.hadoop.fs.s3a.S3AFileSystem" \
    --conf "spark.sql.streaming.checkpointLocation=s3a://bronze-strava/_checkpoints/strava_activities" \
    /opt/spark-apps/kafka_to_minio_raw.py
'

echo "======================================================"
echo "✅ Spark submit disparado"
echo "======================================================"
