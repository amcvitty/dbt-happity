select 
    id as booking_id,
    type as booking_type,
    user_id, 
    email,
    cost_pence, 
    commission_pence as calculated_commission_pence,
    application_fee as charged_commission_pence,
    commission_pence - application_fee as commission_discount_pence,
    stripe_fee_pence, 
    stripe_charge,
    created_at
from {{ source('happity', 'bookings') }}

