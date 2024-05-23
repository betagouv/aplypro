WITH paid_requests AS (
  SELECT
     asp_payment_requests.pfmp_id,
     most_recent_asp_payment_request_transition.created_at AS paid_at
  FROM asp_payment_requests
  INNER JOIN asp_payment_request_transitions AS most_recent_asp_payment_request_transition ON asp_payment_requests.id = most_recent_asp_payment_request_transition.asp_payment_request_id AND most_recent_asp_payment_request_transition.most_recent = TRUE
  WHERE (most_recent_asp_payment_request_transition.to_state IN ('paid')
         AND most_recent_asp_payment_request_transition.to_state IS NOT NULL))
SELECT
  pfmps.*, schoolings.student_id, paid_at
FROM pfmps
INNER JOIN schoolings ON schoolings.id = pfmps.schooling_id
LEFT OUTER JOIN paid_requests ON paid_requests.pfmp_id = pfmps.id
WHERE EXTRACT(ISOYEAR FROM pfmps.end_date ) IN ('2023', '2024');
