select 
    id as event_id, 
    schedule_id, 
    timestamp(start_at) as start_at, 
    timestamp(end_at) as end_at, 
    case when status = 'pending' then 'active' else status end as status,
    cancelled_at, 
    booked_tickets, 
    no_of_tickets as available_tickets,
    created_at

from {{ source('happity', 'events') }}