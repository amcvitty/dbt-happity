select 
    fct_promotions.*,
    
    providers.provider_full_name,
    providers.company_name, 
    providers.provider_region,
    providers.company_id,

    promotion_dates.date_weekday_number as promotion_date_weekday_number,  
    promotion_dates.date_weekday_name as promotion_date_weekday_name ,
    promotion_dates.date_weekday_short_name as promotion_date_weekday_short_name ,
    promotion_dates.date_day_of_month as promotion_date_day_of_month,  
    promotion_dates.date_month_number as promotion_date_month_number,
    promotion_dates.date_month_name as promotion_date_month_name,
    promotion_dates.date_month_short_name as promotion_date_month_short_name ,
    promotion_dates.date_year as promotion_date_year ,
    promotion_dates.date_year_month as promotion_date_year_month ,
    promotion_dates.date_is_weekend as promotion_date_is_weekend,

from {{ ref('fct_promotions') }} fct_promotions
join {{ ref('dim_providers') }} providers using (provider_scd_id)
join {{ ref('dim_dates') }} promotion_dates on promotion_dates.date_date = fct_promotions.promotion_date
