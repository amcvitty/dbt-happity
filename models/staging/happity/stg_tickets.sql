
select 
    id as ticket_id,
    booking_id, 
    event_id, 
    price_id, 
    coalesce(revenue_pence,0) as revenue_pence,
    type as ticket_type, 
    created_at   
from {{ source('happity', 'tickets') }}
