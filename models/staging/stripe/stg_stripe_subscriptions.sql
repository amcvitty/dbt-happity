with subscriptions as (
    select 
        id as stripe_subscription_id,
        customer as stripe_customer_id,
        -- status,
        -- timestamp_seconds(created) as created_ts,
        -- timestamp_seconds(start) as start_date_ts,
        -- cancel_at_period_end
        plan,
        items,
        start,
        ended_at,
        status,
        billing,
        created,
        discount,
        customer,
        discount,
        livemode,
        metadata,
        quantity,
        trial_start,
        trial_end,
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