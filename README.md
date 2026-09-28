# xengine-consumer-clickhouse

The realtime/serving team's dbt project on **ClickHouse** (dbt-clickhouse), the fourth engine in the cross-engine estate beside
Athena (producer), Snowflake and Azure Databricks (consumers). It depends on the other teams only through `models/_sources.yml`:
the producer's Glue-managed Iceberg tables (`glue:stock_common_mesh.*`), read **in place** through `iceberg()` views that
`on-run-start` creates from the S3 locations in `dbt_project.yml` — no copy, no sync job. Models are MergeTree serving tables.

    ./xdbt.sh build
    ./xdbt.sh docs generate

ClickHouse 23.8 reads Iceberg with the https bucket URL and the instance role's credentials; Glue-catalog databases need 25.12+.
