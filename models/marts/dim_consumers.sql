with cl as (   
        select * from {{ ref('stg_consumer_leads') }}
    ), 
    users as (
        select * from {{ ref('stg_users_scd') }} -- where scd_active = 1
    )
select cl.consumer_lead_id, email, from cl
union all
select user_id, email from users

