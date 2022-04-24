with subscription_plan as (
    select 
        _airbyte_subscriptions_hashid,
        id,
        name,
        tiers,
        active,
        amount,
        object,
        created,
        product as stripe_product_id,
        currency,
        `interval`,
        livemode,
        metadata,
        nickname,
        tiers_mode,
        usage_type,
        billing_scheme,
        interval_count,
        aggregate_usage,
        transform_usage,
        trial_period_days,
        statement_descriptor,
        statement_description,
        -- _airbyte_ab_id,
        -- _airbyte_emitted_at,
        -- _airbyte_normalized_at,
        -- _airbyte_plan_hashid`

    from {{ source('stripe', 'subscriptions_plan') }}
)

select * from subscription_plan