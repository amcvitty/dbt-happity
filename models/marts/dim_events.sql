-- this one is not tested/finished

with events as (
    select * from {{ ref('stg_events_scd') }}
), schedules as (
    select * from {{ ref('stg_schedules_scd') }}
), providers as (
    select * from {{ ref('stg_providers_scd') }}
)
select events.*,
    schedules.provider_id
from events
join schedules using (schedule_id)
join providers using (provider_id)
where events.start_at >= schedules.scd_start_at and events.end_at < schedules.scd_end_at
and events.start_at >= providers.scd_start_at and events.end_at < providers.scd_end_at