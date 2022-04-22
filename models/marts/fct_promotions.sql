with promotions as (
        select * from {{ ref('stg_promotions') }}
    ), 
    providers_scd as (
        select * from {{ ref('stg_providers_scd') }}
    )
select
    promotion_id,
    promotion_date,
    provider_scd_id, 
    schedule_id,
    0.01 as happity_revenue_pounds
from promotions 
join providers_scd using (provider_id)
where promotions.created_at >= providers_scd.scd_start_at and promotions.created_at < providers_scd.scd_end_at