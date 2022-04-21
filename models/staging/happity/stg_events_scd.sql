select 
    id as event_id, 
    schedule_id, 
    start_at, 
    end_at, 
    case when status = 'pending' then 'active' else status end as status,
    cancelled_at, 
    booked_tickets, 
    no_of_tickets as available_tickets,
    created_at,
    _airbyte_start_at as scd_start_at,
    _airbyte_end_at as scd_end_at
    
from {{ source('happity', 'events_scd') }}