USE bookmyshow_ticketing;

SHOW TABLES;

DESCRIBE users;
DESCRIBE theatres;
DESCRIBE screens;
DESCRIBE movies;
DESCRIBE seats;
DESCRIBE shows;
DESCRIBE bookings;
DESCRIBE booking_seats;
DESCRIBE payments;
DESCRIBE payment_webhook_events;
DESCRIBE seat_holds;

SELECT show_id, seat_id, COUNT(*) AS booking_count
FROM booking_seats
GROUP BY show_id, seat_id
HAVING COUNT(*) > 1;

SHOW INDEX FROM shows;

SHOW INDEX FROM payment_webhook_events;

SHOW INDEX FROM booking_seats;

SELECT 'users' AS table_name, COUNT(*) AS total FROM users
UNION ALL
SELECT 'theatres', COUNT(*) FROM theatres
UNION ALL
SELECT 'screens', COUNT(*) FROM screens
UNION ALL
SELECT 'movies', COUNT(*) FROM movies
UNION ALL
SELECT 'seats', COUNT(*) FROM seats
UNION ALL
SELECT 'shows', COUNT(*) FROM shows
UNION ALL
SELECT 'bookings', COUNT(*) FROM bookings
UNION ALL
SELECT 'booking_seats', COUNT(*) FROM booking_seats
UNION ALL
SELECT 'payments', COUNT(*) FROM payments
UNION ALL
SELECT 'payment_webhook_events', COUNT(*) FROM payment_webhook_events
UNION ALL
SELECT 'seat_holds', COUNT(*) FROM seat_holds;
