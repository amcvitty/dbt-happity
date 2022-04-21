
select 
    id as ticket_id,
    booking_id, 
    event_id, 
    price_id, 
    cost_pence, 
    revenue_pence,
    type as ticket_type, 
    created_at   
from {{ source('happity', 'tickets') }}
