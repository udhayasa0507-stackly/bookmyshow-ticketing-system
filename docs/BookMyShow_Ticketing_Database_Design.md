# BookMyShow Ticketing System — Database Design

**Project:** Airtribe Institute AI Learning Project  
**Database:** MySQL 8.0  
**Author:** Udhaya Sankar

## 1. Problem Statement

Design a relational database for a movie-ticket booking platform inspired by BookMyShow. Users should be able to view upcoming dates, select a theatre and date, browse available movies and showtimes, and book seats.

The database must support data integrity, prevent duplicate seat bookings, record temporary seat holds, and provide a foundation for idempotent payment processing.

## 2. Requirements

- Store users, theatres, screens, movies, physical seats, and shows.
- Retrieve all shows for a specified theatre and date.
- Store bookings and the seats associated with each booking.
- Prevent the same seat from being booked more than once for a given show.
- Record temporary seat holds and their expiry times.
- Store payment transactions and webhook events.
- Use primary keys, foreign keys, unique constraints, and indexes.

## 3. Entities and Attributes

### 3.1 Users

| Attribute | Data type | Constraint |
|---|---|---|
| user_id | BIGINT UNSIGNED | Primary key, auto-increment |
| full_name | VARCHAR(100) | NOT NULL |
| email | VARCHAR(255) | NOT NULL, UNIQUE |
| phone | VARCHAR(20) | Optional |
| created_at | TIMESTAMP | Default current timestamp |

### 3.2 Theatres

| Attribute | Data type | Constraint |
|---|---|---|
| theatre_id | BIGINT UNSIGNED | Primary key |
| theatre_name | VARCHAR(150) | NOT NULL |
| city | VARCHAR(100) | NOT NULL |
| address | VARCHAR(255) | NOT NULL |
| created_at | TIMESTAMP | Default current timestamp |

### 3.3 Screens

| Attribute | Data type | Constraint |
|---|---|---|
| screen_id | BIGINT UNSIGNED | Primary key |
| theatre_id | BIGINT UNSIGNED | Foreign key to theatres |
| screen_name | VARCHAR(100) | NOT NULL |

A screen belongs to one theatre. The combination of theatre_id and screen_name is unique.

### 3.4 Movies

| Attribute | Data type | Constraint |
|---|---|---|
| movie_id | BIGINT UNSIGNED | Primary key |
| title | VARCHAR(200) | NOT NULL |
| language | VARCHAR(50) | NOT NULL |
| duration_minutes | SMALLINT UNSIGNED | NOT NULL |
| certificate | VARCHAR(20) | Optional |
| release_date | DATE | Optional |

### 3.5 Seats

| Attribute | Data type | Constraint |
|---|---|---|
| seat_id | BIGINT UNSIGNED | Primary key |
| screen_id | BIGINT UNSIGNED | Foreign key to screens |
| row_label | VARCHAR(10) | NOT NULL |
| seat_number | SMALLINT UNSIGNED | NOT NULL |
| seat_type | ENUM | REGULAR, PREMIUM, RECLINER |

A seat position is unique within a screen using (screen_id, row_label, seat_number).

### 3.6 Shows

| Attribute | Data type | Constraint |
|---|---|---|
| show_id | BIGINT UNSIGNED | Primary key |
| movie_id | BIGINT UNSIGNED | Foreign key to movies |
| screen_id | BIGINT UNSIGNED | Foreign key to screens |
| show_date | DATE | NOT NULL |
| start_time | TIME | NOT NULL |
| end_time | TIME | NOT NULL |
| language | VARCHAR(50) | NOT NULL |
| ticket_price | DECIMAL(10,2) | NOT NULL |

Indexes support theatre/date, date/time, and movie/date queries.

### 3.7 Bookings

| Attribute | Data type | Constraint |
|---|---|---|
| booking_id | BIGINT UNSIGNED | Primary key |
| user_id | BIGINT UNSIGNED | Foreign key to users |
| show_id | BIGINT UNSIGNED | Foreign key to shows |
| booking_reference | VARCHAR(50) | UNIQUE |
| status | ENUM | PENDING, CONFIRMED, CANCELLED, EXPIRED |
| total_amount | DECIMAL(10,2) | NOT NULL |
| created_at | TIMESTAMP | Default current timestamp |
| expires_at | TIMESTAMP | Optional |
| confirmed_at | TIMESTAMP | Optional |

### 3.8 Booking Seats

| Attribute | Data type | Constraint |
|---|---|---|
| booking_seat_id | BIGINT UNSIGNED | Primary key |
| booking_id | BIGINT UNSIGNED | Foreign key to bookings |
| show_id | BIGINT UNSIGNED | Foreign key to shows |
| seat_id | BIGINT UNSIGNED | Foreign key to seats |
| price | DECIMAL(10,2) | NOT NULL |

The unique constraint on (show_id, seat_id) prevents duplicate booking-seat records for the same seat and show.

### 3.9 Payments

| Attribute | Data type | Constraint |
|---|---|---|
| payment_id | BIGINT UNSIGNED | Primary key |
| booking_id | BIGINT UNSIGNED | Foreign key to bookings |
| provider | VARCHAR(50) | NOT NULL |
| provider_payment_id | VARCHAR(150) | NOT NULL |
| amount | DECIMAL(10,2) | NOT NULL |
| status | ENUM | PENDING, SUCCESS, FAILED, REFUNDED |
| created_at | TIMESTAMP | Default current timestamp |
| updated_at | TIMESTAMP | Automatically updated |

The combination of provider and provider_payment_id is unique.

### 3.10 Payment Webhook Events

| Attribute | Data type | Constraint |
|---|---|---|
| webhook_event_id | BIGINT UNSIGNED | Primary key |
| provider | VARCHAR(50) | NOT NULL |
| event_id | VARCHAR(150) | NOT NULL |
| event_type | VARCHAR(100) | NOT NULL |
| payload | JSON | NOT NULL |
| processed | BOOLEAN | Default FALSE |
| received_at | TIMESTAMP | Default current timestamp |
| processed_at | TIMESTAMP | Optional |

The combination of provider and event_id is unique to identify duplicate webhook deliveries.

### 3.11 Seat Holds

| Attribute | Data type | Constraint |
|---|---|---|
| hold_id | BIGINT UNSIGNED | Primary key |
| show_id | BIGINT UNSIGNED | Foreign key to shows |
| seat_id | BIGINT UNSIGNED | Foreign key to seats |
| user_id | BIGINT UNSIGNED | Foreign key to users |
| hold_token | VARCHAR(100) | UNIQUE |
| status | ENUM | ACTIVE, RELEASED, CONVERTED, EXPIRED |
| expires_at | TIMESTAMP | NOT NULL |
| created_at | TIMESTAMP | Default current timestamp |

Seat holds record the intended ownership and expiry of temporary reservations. Application logic must ensure that only one valid active hold can control a seat for a given show.

## 4. Sample Data

The sample dataset includes:

- Three users.
- Three theatres in Chennai.
- Five screens.
- Three movies.
- Physical seats for the first two screens.
- Seven sample shows on 6 October 2026.
- Two sample bookings.
- Three booking-seat records.
- Two payment records.

Sample booking-seat records:

| booking_id | show_id | seat_id | price |
|---:|---:|---:|---:|
| 1 | 1 | 1 | 180.00 |
| 1 | 1 | 2 | 180.00 |
| 2 | 4 | 11 | 180.00 |

These examples are for demonstrating the schema and SQL queries.

## 5. Normalization

### First Normal Form (1NF)

Each column stores a single atomic value. Repeating sets of seats and shows are represented as separate rows rather than multiple values in one column.

### Second Normal Form (2NF)

Non-key attributes must depend on the whole candidate key. The schema uses separate entities and explicit primary keys. Junction and transaction tables use unique constraints to represent the relevant business keys.

### Third Normal Form (3NF)

Entity-specific attributes are separated. For example, theatre addresses are stored in theatres, movie titles in movies, and customer email addresses in users. This reduces duplication and update anomalies.

### Boyce–Codd Normal Form (BCNF)

For BCNF, every non-trivial functional dependency X → Y must have X as a superkey. Each table's candidate keys and functional dependencies should be documented and checked before claiming formal BCNF compliance. Primary keys and selected unique constraints help enforce the intended dependencies.

## 6. P1 — SQL Schema and Integrity

The schema is implemented in `sql/02_create_tables.sql`.

Key integrity mechanisms include:

- Primary keys identify records.
- Foreign keys maintain relationships.
- Unique user emails and booking references prevent duplicate identifiers.
- Unique (show_id, seat_id) protects the recorded booking-seat state.
- Unique payment provider identifiers protect payment transaction identity.
- Unique (provider, event_id) enables webhook deduplication.
- CHECK constraints validate non-negative prices and amounts and valid show times.

## 7. P2 — Showtimes for a Theatre and Date

The SQL in `sql/05_p2_queries.sql` joins shows to screens, theatres, and movies.

It filters by the selected theatre and show date, then orders results by start time.

For theatre ID 1 and date 2026-10-06, the sample query returns six shows across two screens.

This query provides the movie titles, languages, screen names, show timings, and ticket prices required by the assignment.

## 8. Concurrency and Double-Booking Prevention

### Unique database constraint

The database defines:

`UNIQUE (show_id, seat_id)`

An attempted duplicate insert returns MySQL error 1062. This behavior was manually verified against the sample database.

### Temporary seat holds

A production implementation can use Redis atomic operations with a TTL to acquire temporary seat holds. Hold ownership and expiry must be validated before a booking is confirmed. Expired holds must be released and their persistent records updated.

### Transactional booking

Booking confirmation should use MySQL transactions, suitable row locking or conditional updates, and a final uniqueness constraint. Multi-seat booking must succeed or roll back as one logical operation.

### Payment webhook idempotency

Webhook event IDs should be stored under a unique provider/event key. Event persistence and payment state transitions should be transactional so duplicate delivery cannot apply the same payment twice.

**Implementation status:** The SQL uniqueness safeguard has been tested. Redis locking, automatic hold expiration, transactional payment processing, and a high-concurrency load test are design requirements for future implementation and have not yet been validated end to end.

## 9. Indexing and Query Optimization

Indexes are defined for common lookups:

- Shows by screen and date.
- Shows by date and start time.
- Shows by movie and date.
- Booking records by user and status.
- Booking seats by booking.
- Holds by status and expiry.
- Webhook events by processed status and received time.

Query plans should be reviewed with `EXPLAIN`, and indexes should be adjusted using measured workload and data volume.

## 10. Testing and Verification

The SQL scripts provide the following checks:

- `SHOW TABLES` and `DESCRIBE` for schema verification.
- Row counts for sample data.
- The P2 showtime query.
- Duplicate booking-seat detection.
- Unique index inspection.
- Expired active-hold queries.
- Payment webhook index inspection.

The duplicate-seat test was successful: inserting an existing show/seat pair was rejected by the unique constraint.

A future load test should simulate concurrent users competing for the same seats and record throughput, latency, failures, and final database consistency.

## 11. Project Files

- `sql/01_create_database.sql` — database creation.
- `sql/02_create_tables.sql` — table definitions and constraints.
- `sql/03_insert_sample_data.sql` — example records.
- `sql/04_p1_queries.sql` — P1 verification queries.
- `sql/05_p2_queries.sql` — P2 showtime query.
- `sql/06_concurrency_tests.sql` — integrity and concurrency-related checks.

## 12. Conclusion

This project establishes a normalized MySQL schema for a movie-ticket booking system. It demonstrates relational modelling, showtime retrieval, uniqueness constraints, indexing, and a foundation for concurrency-safe booking and idempotent payment processing.

The database design is a starting point for a complete ticketing backend; application-level locking, timed hold release, payment handling, and load testing remain necessary to validate production-scale behavior.
