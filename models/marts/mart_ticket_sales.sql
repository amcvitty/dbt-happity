select 
    fct_tickets.*,
    
    providers.provider_full_name,
    providers.company_name, 
    providers.provider_region,
    providers.company_id,

    event_dates.date_weekday_number as event_date_weekday_number,  
    event_dates.date_weekday_name as event_date_weekday_name ,
    event_dates.date_weekday_short_name as event_date_weekday_short_name ,
    event_dates.date_day_of_month as event_date_day_of_month,  
    event_dates.date_month_number as event_date_month_number ,
    event_dates.date_month_name as event_date_month_name ,
    event_dates.date_month_short_name as event_date_month_short_name ,
    event_dates.date_year as event_date_year ,
    event_dates.date_year_month as event_date_year_month ,
    event_dates.date_year_week as event_date_year_week ,
    event_dates.date_is_weekend as event_date_is_weekend,

    booking_dates.date_weekday_number as booking_date_weekday_number,  
    booking_dates.date_weekday_name as booking_date_weekday_name ,
    booking_dates.date_weekday_short_name as booking_date_weekday_short_name ,
    booking_dates.date_day_of_month as booking_date_day_of_month,  
    booking_dates.date_month_number as booking_date_month_number ,
    booking_dates.date_month_name as booking_date_month_name ,
    booking_dates.date_month_short_name as booking_date_month_short_name ,
    booking_dates.date_year as booking_date_year ,
    booking_dates.date_year_month as booking_date_year_month ,
    booking_dates.date_year_week as booking_date_year_week ,
    booking_dates.date_is_weekend as booking_date_is_weekend


from {{ ref('fct_tickets') }} fct_tickets
join {{ ref('dim_providers') }} providers using (provider_scd_id)
join {{ ref('dim_dates') }} event_dates on event_dates.date_date = fct_tickets.event_date
join {{ ref('dim_dates') }} booking_dates on booking_dates.date_date = fct_tickets.booking_date
