with bookings as (
    select * from {{ ref('stg_bookings') }}
), 
tickets as (
    select * from {{ ref('stg_tickets') }}
),
events as (
    select * from {{ ref('stg_events') }}
),
fct_tickets as (
    select 
        tickets.ticket_id,
        tickets.booking_id, -- note this is a https://en.wikipedia.org/wiki/Degenerate_dimension
        tickets.event_id, 
        tickets.ticket_type, -- e.g. Block/Term/Single
        case when bookings.booking_type = 'ConsumerBooking' then 'Happity Website' else 'Provider Manual' end as sold_on_happity,
        tickets.price_id, 
        date(bookings.created_at) as booking_date,
        date(events.start_at) as event_date,
        
        bookings.user_id, 
        bookings.email,
        
        -- Financials here. Note we're avoiding divide by zero errors for free bookings
        tickets.revenue_pence as ticket_consumer_price_pence,
        case when bookings.cost_pence = 0 then 0 else bookings.calculated_commission_pence * tickets.revenue_pence / bookings.cost_pence end as calculated_commission_pence,
        case when bookings.cost_pence = 0 then 0 else bookings.charged_commission_pence    * tickets.revenue_pence / bookings.cost_pence end as charged_commission_pence,
        case when bookings.cost_pence = 0 then 0 else bookings.commission_discount_pence   * tickets.revenue_pence / bookings.cost_pence end as commission_discount_pence,
        case when bookings.cost_pence = 0 then 0 else bookings.stripe_fee_pence            * tickets.revenue_pence / bookings.cost_pence end as stripe_fee_pence

    from tickets
    left join bookings using (booking_id)
    join events on events.event_id = tickets.event_id 
)
select * from fct_tickets
