USE bookmyshow_ticketing;


SET @selected_theatre_id = 1;
SET @selected_date = '2026-10-06';

SELECT
    t.theatre_name,
    t.city,
    m.title AS movie_title,
    m.language AS movie_language,
    m.duration_minutes,
    sc.screen_name,
    s.show_date,
    s.start_time,
    s.end_time,
    s.ticket_price
FROM shows AS s
JOIN screens AS sc
    ON sc.screen_id = s.screen_id
JOIN theatres AS t
    ON t.theatre_id = sc.theatre_id
JOIN movies AS m
    ON m.movie_id = s.movie_id
WHERE t.theatre_id = @selected_theatre_id
  AND s.show_date = @selected_date
ORDER BY s.start_time;
