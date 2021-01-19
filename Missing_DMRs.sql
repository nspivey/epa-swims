SELECT COUNT(rq.DMR_period) - COUNT(rc.DATE_RECEIVED)
FROM
  (SELECT pm.ohio_epa_no,
    pr.us_epa_no,
    pr.core_place_name,
    pm.dmr_period,
    SUBSTR(pr.ohio_epa_no,1,8) facn,
    pr.station_code
  FROM
    (SELECT d.dmr_period,
      p.ohio_epa_no,
      p.permit_id
    FROM
      ( SELECT DISTINCT begin_date dmr_period
      FROM swims.measurement_header
      WHERE begin_date >= '01-JAN-20' 
      AND end_date <  '01-JAN-21' 
      ) d,
      swims.permit p
    WHERE p.effective_date <= d.dmr_period
    AND p.OHIO_EPA_NO LIKE '3IH00074%'
    AND p.permit_status IN ('ACTIVE','EXPIRED')
    AND p.effective_date =
      (SELECT MAX(effective_date)
      FROM swims.permit p2
      WHERE SUBSTR(p2.ohio_epa_no,1,8) = SUBSTR(p.ohio_epa_no,1,8)
      AND p2.permit_status            IN ('ACTIVE','EXPIRED')
      AND p2.effective_date           <= d.dmr_period
      )
    ) pm,
    ( SELECT DISTINCT p3.ohio_epa_no,
      p3.us_epa_no,
      cp.core_place_name,
      s.station_code,
      l.limit_type,
      l.begin_date,
      l.end_date,
      se.month
    FROM swims.permit p3,
      swims.sampling_monitor_pt s,
      --coreadmin.core_place_place cpp,
      swims.sampling_station_limits sl,
      swims.limits l,
      swims.season se,
      coreadmin.core_place cp
    WHERE p3.permit_id           = s.permit_id
    AND p3.core_place_id         = cp.core_place_id
    --AND s.core_place_id          = cpp.core_place_place_id2
    --AND cpp.core_place_place_id1 = sl.core_place_id
    AND s.core_place_id = sl.core_place_id
    AND sl.limit_id      = l.limit_id
    AND l.season_type_id = se.season_type_id
    AND p3.OHIO_EPA_NO LIKE '3IH00074%'
    AND p3.permit_status         IN ('ACTIVE','EXPIRED')
    AND p3.effective_date         < '01-JAN-21' --end date
    AND l.measuring_frequency_id <>
      (SELECT measuring_frequency_id
      FROM swims.measuring_frequency
      WHERE frequency_name = 'When Disch.'
      )
    ) pr
  WHERE pm.ohio_epa_no = pr.ohio_epa_no
  AND ((pm.dmr_period BETWEEN pr.begin_date AND pr.end_date)
  OR (pr.limit_type                          = 93
  AND pm.dmr_period                         >= pr.begin_date))
  AND to_number(TO_CHAR(pm.dmr_period,'MM')) = pr.month
  ORDER BY pm.dmr_period,
    pr.station_code,
    pr.month
  ) rq,
  (SELECT SUBSTR(mh.ohio_epa_no,1,8) facn,
    mh.station_code,
    mh.begin_date dmr_period,
    mh.date_received
  FROM swims.measurement_header mh,
    swims.signature_block sb,
    swims.notes nt
  WHERE mh.srh_id = sb.link_id (+)
  AND mh.srh_id   =nt.link_id(+)
  AND mh.OHIO_EPA_NO LIKE '3IH00074%'
  AND mh.begin_date >= '01-JAN-20'
  AND mh.end_date    < '01-JAN-21'
  ) rc
WHERE rq.facn       = rc.facn (+)
AND rq.station_code = rc.station_code (+)
AND rq.dmr_period   = rc.dmr_period;