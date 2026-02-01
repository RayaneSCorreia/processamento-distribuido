from pyspark.sql import SparkSession
from pyspark.sql.functions import col, from_json, current_timestamp, expr
from pyspark.sql.types import StructType, StructField, StringType, LongType, DoubleType, IntegerType

spark = SparkSession.builder.appName("strava-kafka-to-postgres").getOrCreate()
spark.sparkContext.setLogLevel("WARN")

KAFKA_BOOTSTRAP = "kafka_cdc_strava:29092"
TOPIC = "strava_source.public.strava_activities"

PG_HOST = "postgres_dest_cdc_strava"
PG_PORT = "5432"
PG_DB   = "strava_dest"
PG_USER = "postgres"
PG_PASS = "postgrespassword"

TARGET_TABLE = "public.silver_strava_activities"
STAGE_TABLE  = "public.silver_strava_activities_stage"

JDBC_URL = f"jdbc:postgresql://{PG_HOST}:{PG_PORT}/{PG_DB}"
JDBC_PROPS = {"user": PG_USER, "password": PG_PASS, "driver": "org.postgresql.Driver"}

after_schema = StructType([
    StructField("activity_id", LongType(), False),
    StructField("activity_name", StringType(), True),
    StructField("activity_sport_type", StringType(), True),
    StructField("activity_distance", DoubleType(), True),
    StructField("activity_moving_time", IntegerType(), True),
    StructField("activity_start_date", LongType(), True),   # micros
    StructField("activity_updated_at", LongType(), True),   # micros
    StructField("activity_device_name", StringType(), True),
    StructField("activity_entry_source", StringType(), True),
])

debezium_payload_schema = StructType([
    StructField("payload", StructType([
        StructField("before", after_schema, True),
        StructField("after",  after_schema, True),
        StructField("op",     StringType(), False),
        StructField("ts_ms",  LongType(), True),
    ]), True)
])

df_kafka = (
    spark.read
    .format("kafka")
    .option("kafka.bootstrap.servers", KAFKA_BOOTSTRAP)
    .option("subscribe", TOPIC)
    .option("startingOffsets", "earliest")
    .option("endingOffsets", "latest")
    .option("failOnDataLoss", "false")
    .load()
)

df_json = df_kafka.filter(col("value").isNotNull()).selectExpr("CAST(value AS STRING) AS json")
df_parsed = df_json.select(from_json(col("json"), debezium_payload_schema).alias("root"))

df_out = (
    df_parsed
    .select(
        col("root.payload.after").alias("after"),
        col("root.payload.op").alias("op"),
        col("root.payload.ts_ms").alias("cdc_ts_ms"),
        current_timestamp().alias("ingestion_ts"),
    )
    .filter(col("op").isin(["c", "u", "r"]))
    .filter(col("after").isNotNull())
    .filter(col("after.activity_id").isNotNull())
    .select(
        col("after.activity_id").alias("activity_id"),
        col("after.activity_name").alias("activity_name"),
        col("after.activity_sport_type").alias("activity_sport_type"),
        col("after.activity_distance").alias("activity_distance"),
        col("after.activity_moving_time").alias("activity_moving_time"),
        expr("timestamp_micros(after.activity_start_date)").alias("activity_start_date"),
        expr("timestamp_micros(after.activity_updated_at)").alias("activity_updated_at"),
        col("after.activity_device_name").alias("activity_device_name"),
        col("after.activity_entry_source").alias("activity_entry_source"),
        col("op").alias("cdc_op"),
        col("cdc_ts_ms").alias("cdc_ts_ms"),
        col("ingestion_ts").alias("ingestion_ts"),
    )
)

rows = df_out.count()
print(f"Rows para gravar no stage: {rows}")
if rows > 0:
    (df_out.write
        .mode("overwrite")
        .option("truncate", "true")
        .jdbc(JDBC_URL, STAGE_TABLE, properties=JDBC_PROPS)
    )

spark.stop()
