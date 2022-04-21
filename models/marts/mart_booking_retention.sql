-- Adapted from https://www.holistics.io/blog/calculate-cohort-retention-analysis-with-sql/
with 
    bookings as (
        select * from {{ ref('stg_bookings') }}
    ),
    -- (user_email, cohort_month), each user with the month of their first booking
    cohort_items as (
        select
            date_trunc( date(min(b.created_at)), MONTH) as cohort_month,
            email as user_email
        from bookings b
        group by 2
        order by 1, 2
    ),
    -- (user_id, month_number): user X has activity in month number X
    user_activities as (
        select
            A.email as user_email,
            DATE_DIFF(
                date_trunc(date(A.created_at), MONTH),
                C.cohort_month,
                MONTH
            ) as month_number
            -- possibly add in revenue etc. here
        from bookings A
        left join cohort_items C ON A.email = C.user_email
        group by 1, 2
    ),
    cohort_size as (
        select cohort_month, count(1) as num_users
        from cohort_items
        group by 1
        order by 1
    ),
    retention_table as (
        select
            C.cohort_month,
            A.month_number,
            count(1) as num_users
        from user_activities A
        left join cohort_items C ON A.user_email = C.user_email
        group by 1, 2
    )
select
  B.cohort_month,
  S.num_users as cohort_size,
  B.month_number,
  B.num_users * 100.0 / S.num_users as percentage
from retention_table B
left join cohort_size S ON B.cohort_month = S.cohort_month
where B.cohort_month IS NOT NULL
order by 1, 3

