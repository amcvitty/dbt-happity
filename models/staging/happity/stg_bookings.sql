select 
    id as booking_id,
    type as booking_type,
    user_id, 
    email,
    coalesce(cost_pence, 0) as cost_pence, 
    coalesce(commission_pence,0) as calculated_commission_pence,
    coalesce(application_fee,0) as charged_commission_pence,
    coalesce(commission_pence - application_fee,0) as commission_discount_pence,
    coalesce(stripe_fee_pence,0) as stripe_fee_pence, 
    stripe_charge,
    created_at
from {{ source('happity', 'bookings') }}

