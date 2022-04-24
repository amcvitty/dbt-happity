with dates as (
    {{ dbt_utils.date_spine(
        datepart="day",
        start_date="cast('2017-01-01' as date)",
        end_date="cast('2040-01-01' as date)"
    )
    }}
)
select 
    -- these can be used as the time dimension because they are actually dates. In particular
    -- you could use them to show totals by week, month or year in a timeseries chart
    d.date_day as date_timestamp,
    DATE(d.date_day) as date_date, 
    date_trunc(d.date_day, YEAR) as date_year,
    date_trunc(d.date_day, MONTH) as date_year_month,
    date_trunc(d.date_day, ISOWEEK) as date_year_week,

    EXTRACT(DAYOFWEEK FROM d.date_day) as date_weekday_number, 
    FORMAT_DATE("%A", d.date_day) as date_weekday_name,
    FORMAT_DATE("%a", d.date_day) as date_weekday_short_name,

    EXTRACT(DAY FROM d.date_day) as date_day_of_month, 

    EXTRACT(MONTH FROM d.date_day) as date_month_number,
    FORMAT_DATE("%B", d.date_day) as date_month_name,
    FORMAT_DATE("%b", d.date_day) as date_month_short_name,


    case when EXTRACT(DAYOFWEEK FROM d.date_day) in (1,7) then 'Weekend' else 'Weekday' end as date_is_weekend
    -- It would be possible to put in other information here about holidays etc.
from
    dates d
order by 1