with subscription_items as (
    select *
        -- id as stripe_subscription_id,
        -- customer as stripe_customer_id,
        -- status,
        -- timestamp_seconds(created) as created_ts,
        -- timestamp_seconds(start) as start_date_ts,
        -- cancel_at_period_end

    from {{ source('stripe', 'subscription_items') }}
)

select * from subscription_items