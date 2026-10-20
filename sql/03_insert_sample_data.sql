USE bookmyshow_ticketing;

INSERT INTO users (full_name, email, phone) VALUES
('Udhaya Sankar', 'udhaya@example.com', '9876543210'),
('Arun Kumar', 'arun@example.com', '9876543211'),
('Priya Devi', 'priya@example.com', '9876543212');

INSERT INTO theatres (theatre_name, city, address) VALUES
('PVR Cinemas', 'Chennai', 'Phoenix Marketcity, Velachery'),
('INOX Cinemas', 'Chennai', 'Express Avenue Mall'),
('AGS Cinemas', 'Chennai', 'T Nagar');

INSERT INTO screens (theatre_id, screen_name) VALUES
(1, 'Screen 1'),
(1, 'Screen 2'),
(2, 'Screen 1'),
(2, 'Screen 2'),
(3, 'Screen 1');

INSERT INTO movies
(title, language, duration_minutes, certificate, release_date)
VALUES
('Coolie', 'Tamil', 165, 'UA', '2026-08-14'),
('The Raja Saab', 'Tamil', 145, 'UA', '2026-09-01'),
('Interstellar', 'English', 169, 'U/A', '2014-11-07');

INSERT INTO seats (screen_id, row_label, seat_number, seat_type) VALUES
(1, 'A', 1, 'REGULAR'),
(1, 'A', 2, 'REGULAR'),
(1, 'A', 3, 'REGULAR'),
(1, 'A', 4, 'REGULAR'),
(1, 'B', 1, 'PREMIUM'),
(1, 'B', 2, 'PREMIUM'),
(1, 'B', 3, 'PREMIUM'),
(1, 'B', 4, 'PREMIUM'),
(1, 'C', 1, 'RECLINER'),
(1, 'C', 2, 'RECLINER');

INSERT INTO seats (screen_id, row_label, seat_number, seat_type) VALUES
(2, 'A', 1, 'REGULAR'),
(2, 'A', 2, 'REGULAR'),
(2, 'A', 3, 'REGULAR'),
(2, 'A', 4, 'REGULAR'),
(2, 'B', 1, 'PREMIUM'),
(2, 'B', 2, 'PREMIUM'),
(2, 'B', 3, 'PREMIUM'),
(2, 'B', 4, 'PREMIUM');

INSERT INTO shows
(movie_id, screen_id, show_date, start_time, end_time, language, ticket_price)
VALUES
(1, 1, '2026-10-06', '10:00:00', '12:45:00', 'Tamil', 180.00),
(1, 1, '2026-10-06', '14:00:00', '16:45:00', 'Tamil', 200.00),
(1, 1, '2026-10-06', '18:00:00', '20:45:00', 'Tamil', 220.00),
(2, 2, '2026-10-06', '11:00:00', '13:25:00', 'Tamil', 180.00),
(2, 2, '2026-10-06', '15:00:00', '17:25:00', 'Tamil', 200.00),
(2, 2, '2026-10-06', '19:00:00', '21:25:00', 'Tamil', 220.00),
(3, 3, '2026-10-06', '09:30:00', '12:19:00', 'English', 250.00);

INSERT INTO bookings
(user_id, show_id, booking_reference, status, total_amount)
VALUES
(1, 1, 'BMS-20261006-0001', 'CONFIRMED', 360.00),
(2, 4, 'BMS-20261006-0002', 'CONFIRMED', 180.00);

INSERT INTO booking_seats (booking_id, show_id, seat_id, price) VALUES
(1, 1, 1, 180.00),
(1, 1, 2, 180.00),
(2, 4, 11, 180.00);

INSERT INTO payments
(booking_id, provider, provider_payment_id, amount, status)
VALUES
(1, 'RAZORPAY', 'pay_demo_000001', 360.00, 'SUCCESS'),
(2, 'RAZORPAY', 'pay_demo_000002', 180.00, 'SUCCESS');
