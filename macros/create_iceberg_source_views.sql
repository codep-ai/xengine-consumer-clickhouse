{# One ClickHouse VIEW per shared Iceberg table, over iceberg(<https S3 location>). The view is what dbt `source()` points at, so the
   manifest carries the dependency and the cross-engine stitcher can join it by meta.physical_identity. No data is copied.
   A var entry is either a URL string, or {url, columns: [...]} when the producer's column names need lower-casing (Snowflake). #}
{% macro create_iceberg_source_views() %}
  {% if execute %}
    {% for fq, spec in var('iceberg_locations').items() %}
      {% set db = fq.split('.')[0] %}{% set tbl = fq.split('.')[1] %}
      {% if spec is string %}{% set url = spec %}{% set select_list = '*' %}
      {% else %}{% set url = spec['url'] %}{% set cols = [] %}
        {% for c in spec['columns'] %}{% do cols.append(c | upper ~ ' as ' ~ c) %}{% endfor %}{% set select_list = cols | join(', ') %}
      {% endif %}
      {% do run_query("create database if not exists " ~ db) %}
      {% do run_query("create or replace view " ~ db ~ "." ~ tbl ~ " as select " ~ select_list ~ " from iceberg('" ~ url ~ "')") %}
      {{ log("iceberg view " ~ fq ~ " -> " ~ url, info=True) }}
    {% endfor %}
  {% endif %}
{% endmacro %}
