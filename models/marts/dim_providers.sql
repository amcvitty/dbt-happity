with providers_scd as (
    select * from {{ ref('stg_providers_scd') }}
), companies as (
    select * from {{ ref('stg_companies') }}
)
select 
    provider_scd_id,
    provider_id, -- not a key for this table
    company_id, 
    companies.name || ', ' || providers_scd.region as provider_full_name, 
    companies.name as company_name,
    region as provider_region,
    area,
    postcode,
    created_at,
    stripe_account_id,
    stripe_customer_id,
    marketing_source
from providers_scd
join companies using (company_id)
    