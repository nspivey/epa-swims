SELECT COUNT(e.EVENT_SCHED_START_DATE)-COUNT(e.event_end_date)
FROM SWIMS.EVENT e
INNER JOIN swims.event_permit ep
ON e.EVENT_ID = ep.EVENT_ID
INNER JOIN
  (SELECT permit_id,
    core_place_id,
    ohio_epa_no,
    us_epa_no,
    effective_date,
    expiration_date
  FROM swims.permit
  WHERE SUBSTR(ohio_epa_no,1,8)='3IH00074'
  AND ('01-JAN-20' BETWEEN swims.permit.EFFECTIVE_DATE AND swims.permit.expiration_date
  OR '01-JAN-21' BETWEEN swims.permit.EFFECTIVE_DATE AND swims.permit.expiration_date)
  AND swims.permit.permit_status IN ('ACTIVE','EXPIRED')
  ) p
ON ep.PERMIT_ID = p.PERMIT_ID
INNER JOIN coreadmin.core_place cp
ON p.core_place_id = cp.core_place_id
INNER JOIN swims.type t
ON e.EVENT_TYPE_ID = t.TYPE_ID
INNER JOIN swims.compliance_milestone cm
ON t.pcs_code               = cm.pcs_code
WHERE SUBSTR(t.type_id,1,3) = '570'
ORDER BY e.EVENT_SCHED_START_DATE ;