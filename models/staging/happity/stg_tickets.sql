with customers as (
    select 
        id as stripe_customer_id,
        email, 
        balance as balance_pence
         
    from {{ source('stripe', 'customers') }}
)

select * from customers