with subscriptions as (
    select 
        _airbyte_subscriptions_hashid,       
        id as stripe_subscription_id,
        customer as stripe_customer_id,
        -- status,
        timestamp_seconds(coalesce(start, created)) as started_at_ts,
        timestamp_seconds(cast(ended_at as int64)) as ended_at_ts,
        timestamp_seconds(cast(trial_start as int64)) as trial_start,
        timestamp_seconds(cast(trial_end as int64)) as trial_end,
        
        status,
        --billing,
        --created,
        discount,
        metadata,
        quantity,
        canceled_at,
        tax_percent,
        days_until_due,
        current_period_end,
        billing_cycle_anchor,
        cancel_at_period_end,
        current_period_start

    from {{ source('stripe', 'subscriptions') }}
)

select * from subscriptions
