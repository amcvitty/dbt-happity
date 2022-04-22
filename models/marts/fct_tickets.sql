with bookings as (
    select * from {{ ref('stg_bookings') }}
), 
tickets as (
    select * from {{ ref('stg_tickets') }}
),
events as (
    select * from {{ ref('stg_events') }}
),
event_providers as (
    select event_id, max(provider_scd_id) as provider_scd_id
    from events
    join {{ ref('int_event_providers') }} event_providers using (event_id)
    join {{ ref('stg_providers_scd') }} providers using (provider_id)
    where events.start_at >= providers.scd_start_at and events.start_at < providers.scd_end_at
    group by 1
),
fct_tickets as (
    select 
        tickets.ticket_id,
        tickets.booking_id, -- note this is a https://en.wikipedia.org/wiki/Degenerate_dimension
        tickets.event_id, 
        event_providers.provider_scd_id,
        tickets.ticket_type, -- e.g. Block/Term/Single
        case when bookings.booking_type = 'ConsumerBooking' then 'Happity Website' else 'Provider Manual' end as sold_on_happity,
        tickets.price_id, 
        date(bookings.created_at) as booking_date,
        date(events.start_at) as event_date,
        
        bookings.email as consumer_email,
        
        -- Financials here. Note we're avoiding divide by zero errors for free bookings
        tickets.revenue_pence /100 as ticket_consumer_price_pounds,
        case when bookings.cost_pence = 0 then 0 else bookings.calculated_commission_pence * tickets.revenue_pence / bookings.cost_pence end /100 as calculated_commission_pounds,
        case when bookings.cost_pence = 0 then 0 else bookings.charged_commission_pence    * tickets.revenue_pence / bookings.cost_pence end /100 as charged_commission_pounds,
        case when bookings.cost_pence = 0 then 0 else bookings.commission_discount_pence   * tickets.revenue_pence / bookings.cost_pence end /100 as commission_discount_pounds,
        case when bookings.cost_pence = 0 then 0 else bookings.stripe_fee_pence            * tickets.revenue_pence / bookings.cost_pence end /100 as stripe_fee_pounds
    from tickets
    join bookings using (booking_id)
    join events using (event_id)
    join event_providers using (event_id)
)
select * from fct_tickets

