select providers.provider_full_name, subscriptions.*
from {{ ref('dim_providers') }} providers 
join {{ ref('stg_stripe_subscriptions') }} subscriptions using (stripe_customer_id )