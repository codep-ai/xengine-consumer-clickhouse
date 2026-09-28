-- Built BY CLICKHOUSE on tables ATHENA produced: the Athena -> ClickHouse crossing. Serving-tier shape: one row per ticker with the
-- latest close and the 5-trading-day change, the kind of table a broker's live dashboard reads. MergeTree, ordered by ticker.
-- Subquery rather than a CTE: ClickHouse 23.8 cannot resolve the ORDER BY key when dbt wraps `WITH ... SELECT` in `CREATE TABLE ... AS (...)`.
{{ config(order_by='(ticker)') }}
select
    l.ticker,
    l.exchange,
    t.company_name,
    t.sector,
    e.country,
    l.trade_date                                             as last_trade_date,
    l.currency_code,
    l.close                                                  as last_close,
    l.close_usd                                              as last_close_usd,
    l.volume                                                 as last_volume,
    (l.close_usd - l.close_usd_5d_ago) / l.close_usd_5d_ago  as change_5d
from (
    select
        p.ticker,
        p.exchange,
        p.trade_date,
        p.currency_code,
        p.close,
        p.close_usd,
        p.volume,
        row_number() over (partition by p.ticker order by p.trade_date desc) as rn,
        any(p.close_usd) over (partition by p.ticker order by p.trade_date desc rows between 5 following and 5 following) as close_usd_5d_ago
    from {{ source('stock_common_ch', 'common_price_daily') }} p
) l
left join {{ source('stock_common_ch', 'common_ticker') }}   t on t.ticker = l.ticker
left join {{ source('stock_common_ch', 'common_exchange') }} e on e.exchange = l.exchange
where l.rn = 1
