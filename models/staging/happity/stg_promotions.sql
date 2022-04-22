with stg_promotions as (
    select 
        id as promotion_id,
        date(date) as promotion_date,
        provider_id, 
        promotable_id as schedule_id, -- There is nothing but schedules right now, and I expect that to continue
        timestamp(created_at) as created_at
    from {{ source('happity', 'promotions') }}
    where promotable_type = 'Schedule'
)
select * from stg_promotions 