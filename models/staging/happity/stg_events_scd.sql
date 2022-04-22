select 
    id as event_id, 
    schedule_id, 
    timestamp(start_at) as start_at, 
    timestamp(end_at) as end_at, 
    case when status = 'pending' then 'active' else status end as status,
    cancelled_at, 
    booked_tickets, 
    no_of_tickets as available_tickets,
    created_at,
    timestamp(_airbyte_start_at) as scd_start_at,
    timestamp(coalesce(_airbyte_end_at, '2099-01-01')) as scd_end_at,
    _airbyte_active_row as scd_active

from {{ source('happity', 'events_scd') }}