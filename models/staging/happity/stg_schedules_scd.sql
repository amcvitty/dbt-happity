select 
    id as schedule_id, 
    provider_id,
    venue_id,
    activity_id,
    status,
    published,
    promoted,
    created_at,
    timestamp(_airbyte_start_at) as scd_start_at,
    timestamp(coalesce(_airbyte_end_at, '2099-01-01')) as scd_end_at,
    _airbyte_active_row as scd_active
    
from {{ source('happity', 'schedules_scd') }}
