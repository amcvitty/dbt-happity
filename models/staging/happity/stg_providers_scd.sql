select 
    _airbyte_unique_key_scd as provider_scd_id,
    id as provider_id,
    company_id, 
    area,
    region,
    postcode,
    created_at,
    uid as stripe_account_id,
    stripe_customer_id,
    marketing_source,
    timestamp(_airbyte_start_at) as scd_start_at,
    timestamp(coalesce(_airbyte_end_at, '2099-01-01')) as scd_end_at,
    _airbyte_active_row as scd_active
from {{ source('happity', 'providers_scd') }}