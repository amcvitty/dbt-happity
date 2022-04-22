-- events never change schedule, provider or company, so a bit of brute force
-- If we stashed provider_id on bookings or tickets this might not be necessary, but we don't, so here we are
select event_id, schedule_id, max(provider_id) as provider_id, max(company_id) as company_id
from {{ ref('stg_events_scd') }} events
join {{ ref('stg_schedules_scd')}} schedules using (schedule_id)
join {{ ref('stg_providers_scd')}} providers using (provider_id)
group by 1,2