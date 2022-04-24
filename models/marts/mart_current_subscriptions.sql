select 
    case when providers.provider_full_name is null then 'NO PROVIDER: ' || stripe_customer_id else providers.provider_full_name  end as provider_full_name , 
    stripe_customer_id,
    stripe_subscription_id,
    --subscriptions.*,
    --plans.*,
    plans.amount,
    plans.interval, 
    products.name as product_name,
    status,
    cancel_at_period_end,
    started_at_ts,
    ended_at_ts,
    trial_start,
    trial_end
from {{ ref('stg_stripe_subscriptions') }} subscriptions 
join {{ ref('stg_stripe_subscription_plans') }} plans using (_airbyte_subscriptions_hashid)
join {{ ref('stg_stripe_products') }} products using (stripe_product_id)
left join {{ ref('dim_providers') }} providers using (stripe_customer_id )
where plans.usage_type != 'metered'

