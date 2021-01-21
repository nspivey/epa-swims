SELECT COUNT(DISTINCT CASE WHEN e.event_type_id = 6535 THEN TRUNC(e.event_sched_start_date, 'MM') END) as n_months_w_num_vio
 , SUM(CASE WHEN e.event_type_id = 6535 THEN 1 ELSE 0 END) as n_num_vios
 , SUM(CASE WHEN e.event_type_id = 6536 THEN 1 ELSE 0 END) as n_code_vios
 , SUM(CASE WHEN e.event_type_id = 6537 THEN 1 ELSE 0 END) as n_freq_vios
 , SUM(CASE WHEN e.event_type_id BETWEEN 570000 AND 570999 THEN 1 ELSE 0 END) as n_comp_sch_past_due
 
FROM swims.event e
 INNER JOIN swims.event_permit ep ON e.event_id = ep.event_id
 INNER JOIN swims.permit p ON ep.permit_id = p.permit_id 

WHERE e.expire_flag IS NULL 
 AND SUBSTR(p.ohio_epa_no,1,8) = '3IH00074' 
 AND 
 (
    (
     e.event_type_id IN (6535, 6536, 6537) --numeric vios, code vios, freq. vios
      AND e.event_sched_start_date BETWEEN '01-JAN-20' AND '31-DEC-20' -- BETWEEN is inclusive; original query returned 13 month period
    )
  OR
     (
     e.event_type_id BETWEEN 570000 AND 570999  --compliance schedule milestones
       AND e.event_sched_start_date <= SYSDATE
       AND e.event_end_date IS NULL
       AND p.permit_status = 'ACTIVE'
    )
  );
