select 
    id as provider_id,
    area,
    region,
    postcode,
    created_at,
    uid as stripe_account_id,
    stripe_customer_id,
    marketing_source,
    _airbyte_start_at as scd_start_at,
    _airbyte_end_at as scd_end_at
from {{ source('happity', 'providers_scd') }}