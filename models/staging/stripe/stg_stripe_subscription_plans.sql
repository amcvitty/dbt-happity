with subscription_plan as (
    select 
        *
    from {{ source('stripe', 'subscriptions_plan') }}
)

select * from subscription_plan