select 
    id as payment_id, 
    orderid as order_id, 
    status as payment_status, 
    amount / 100 as dollar_amount

from {{ source('stripe', 'payment') }}