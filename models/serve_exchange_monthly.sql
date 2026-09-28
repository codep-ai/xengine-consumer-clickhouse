-- Built BY CLICKHOUSE on a mart SNOWFLAKE produced: the Snowflake -> ClickHouse crossing. Same shape as the Databricks team's
-- feat_exchange_monthly, so the three consumers can be compared like for like. Read in place from the Snowflake-managed Iceberg files.
-- DISABLED on ClickHouse 23.8: the Snowflake-managed Iceberg data files use Parquet DELTA_LENGTH_BYTE_ARRAY encoding, which this
-- ClickHouse version's Parquet reader does not decode ("Not yet implemented: DecodeArrow for DeltaLengthByteArrayDecoder").
-- The view stock_consumer_mesh.mart_price_monthly_usd is created and its schema reads; the data does not. Re-enable after a ClickHouse upgrade.
{{ config(enabled=false, order_by='(exchange, currency_code, month_start)') }}
select
    m.exchange,
    m.currency_code,
    m.month_start,
    count(distinct m.ticker)      as tickers,
    avg(m.avg_close_usd)          as avg_close_usd,
    sum(m.total_volume)           as total_volume
from {{ source('stock_consumer_sf_ch', 'mart_price_monthly_usd') }} m
group by m.exchange, m.currency_code, m.month_start
