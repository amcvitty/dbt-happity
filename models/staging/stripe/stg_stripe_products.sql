select 
    id as stripe_product_id,
    name
from {{ source('stripe_manual', 'products') }}
