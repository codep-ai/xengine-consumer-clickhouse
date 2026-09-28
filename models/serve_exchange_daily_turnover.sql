-- Built BY CLICKHOUSE on tables ATHENA produced. Daily turnover per exchange in USD for the last 90 trading days: the realtime
-- tier's equivalent of the analytics team's Snowflake mart, computed on the same Iceberg copy without moving it.
{{ config(order_by='(exchange, trade_date)') }}
select
    p.exchange,
    e.country,
    e.currency_code,
    p.trade_date,
    count(distinct p.ticker)            as tickers_traded,
    sum(p.close_usd * p.volume)         as turnover_usd
from {{ source('stock_common_ch', 'common_price_daily') }} p
left join {{ source('stock_common_ch', 'common_exchange') }} e on e.exchange = p.exchange
where p.trade_date >= (select max(trade_date) from {{ source('stock_common_ch', 'common_price_daily') }}) - 130
group by p.exchange, e.country, e.currency_code, p.trade_date
