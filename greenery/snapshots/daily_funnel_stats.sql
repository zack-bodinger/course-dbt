{% snapshot daily_funnel_stats_snapshot %}

  {{
    config(
      target_schema='snapshots',
      unique_key='valid_at_timestamp_utc',
      strategy='timestamp',
      updated_at='valid_at_timestamp_utc'
    )
  }}

  SELECT * FROM {{ ref('daily_funnel_stats') }}

{% endsnapshot %}