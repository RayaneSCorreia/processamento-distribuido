from pyspark.sql import SparkSession
from pyspark.sql.functions import col, from_json, current_timestamp
from pyspark.sql.types import *

spark = (
    SparkSession.builder
    .appName("strava-cdc-raw-structured")
    .getOrCreate()
)

spark.sparkContext.setLogLevel("WARN")

KAFKA_BOOTSTRAP = "kafka_cdc_strava:29092"
TOPIC = "strava_source.public.strava_activities"
MINIO_BUCKET = "bronze-strava"

strava_schema = StructType([
    StructField("id", LongType()),
    StructField("athlete_id", LongType()),
    StructField("distance", DoubleType()),
    StructField("elapsed_time", IntegerType()),
    StructField("activity_type", StringType()),
    StructField("start_date", StringType()),
    StructField("created_at", StringType()),
    StructField("updated_at", StringType())
])

debezium_schema = StructType([
    StructField("before", strava_schema),
    StructField("after", strava_schema),
    StructField("op", StringType()),
    StructField("ts_ms", LongType())
])

df_kafka = (
    spark.readStream
    .format("kafka")
    .option("kafka.bootstrap.servers", KAFKA_BOOTSTRAP)
    .option("subscribe", TOPIC)
    .option("startingOffsets", "latest")
    .load()
)

df_parsed = (
    df_kafka
    .selectExpr("CAST(value AS STRING) as json")
    .select(from_json(col("json"), debezium_schema).alias("data"))
    .select(
        col("data.after").alias("record"),
        col("data.op"),
        col("data.ts_ms"),
        current_timestamp().alias("ingestion_ts")
    )
)

query = (
    df_parsed.writeStream
    .format("parquet")
    .option("checkpointLocation", f"s3a://{MINIO_BUCKET}/_checkpoints/strava_activities")
    .option("path", f"s3a://{MINIO_BUCKET}/strava_activities")
    .outputMode("append")
    .start()
)

query.awaitTermination(30)
query.stop()