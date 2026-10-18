USE bookmyshow_ticketing;

SELECT
    show_id,
    seat_id,
    COUNT(*) AS booking_count
FROM booking_seats
GROUP BY show_id, seat_id
HAVING COUNT(*) > 1;

SHOW INDEX FROM booking_seats;

SHOW INDEX FROM seat_holds;

SELECT
    hold_id,
    show_id,
    seat_id,
    status,
    expires_at
FROM seat_holds
WHERE status = 'ACTIVE'
  AND expires_at <= CURRENT_TIMESTAMP;
