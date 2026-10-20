# BookMyShow Ticketing System

A MySQL-based database design for a high-concurrency movie ticket booking platform inspired by BookMyShow. This project focuses on normalized relational database design, theatre showtime queries, seat-level double-booking prevention, timed seat holds, and idempotent payment webhook processing.

## Project Overview

The system models how users browse movie shows at a theatre on a selected date, choose seats, and create bookings.

The database is designed as a foundation for a scalable ticketing backend, with MySQL constraints and indexes to protect booking integrity and improve query performance.

## Learning Objectives

- Design a relational database using 1NF, 2NF, 3NF, and BCNF principles.
- Identify entities, attributes, primary keys, foreign keys, and candidate keys.
- Query all movie shows for a selected theatre and date.
- Prevent duplicate seat bookings using database uniqueness constraints.
- Understand pessimistic locking, optimistic locking, and Redis-based temporary seat holds.
- Design payment webhook processing with idempotency.
- Apply indexing and concurrency-testing techniques.

## Technology Stack

- **Database:** MySQL 8.0
- **Database client:** MySQL Workbench
- **SQL:** DDL, DML, joins, indexes, constraints, and aggregate queries
- **Version control:** Git and GitHub

## Project Structure

```text
bookmyshow-ticketing-system/
├── docs/
│   ├── BookMyShow_Ticketing_Database_Design.pdf
│   └── screenshots/
├── sql/
│   ├── 01_create_database.sql
│   ├── 02_create_tables.sql
│   ├── 03_insert_sample_data.sql
│   ├── 04_p1_queries.sql
│   ├── 05_p2_queries.sql
│   └── 06_concurrency_tests.sql
└── README.md
```

## Database Schema

The database contains the following 11 tables:

| Table | Purpose |
|---|---|
| `users` | Stores customer details |
| `theatres` | Stores theatre information |
| `screens` | Stores screens belonging to theatres |
| `movies` | Stores movie metadata |
| `seats` | Stores physical seats for each screen |
| `shows` | Stores movie showtimes, dates, and prices |
| `bookings` | Stores customer booking records |
| `booking_seats` | Associates bookings with seats for a specific show |
| `payments` | Stores payment transaction details |
| `payment_webhook_events` | Records payment webhook events for idempotent processing |
| `seat_holds` | Stores temporary seat-hold records and expiry timestamps |

## Setup Instructions

### Prerequisites

- MySQL Server 8.0 or later
- MySQL Workbench or MySQL command-line client
- Git

### 1. Clone the repository

```bash
git clone https://github.com/udhayasa0507-stackly/bookmyshow-ticketing-system.git
cd bookmyshow-ticketing-system
```

### 2. Create the database

Run the following file in MySQL Workbench:

`sql/01_create_database.sql`

Or execute:

```sql
CREATE DATABASE IF NOT EXISTS bookmyshow_ticketing
    CHARACTER SET utf8mb4
    COLLATE utf8mb4_unicode_ci;

USE bookmyshow_ticketing;
```

### 3. Create the tables

Execute:

`sql/02_create_tables.sql`

This creates the relational tables, primary keys, foreign keys, unique constraints, and indexes.

### 4. Insert sample data

Execute:

`sql/03_insert_sample_data.sql`

Run this seed script only once on a fresh database unless the data is reset appropriately.

### 5. Verify the database

Execute:

`sql/04_p1_queries.sql`

Review the table definitions, indexes, uniqueness checks, and sample row counts.

## P1 — Database Design and Normalization

The schema separates customers, theatres, screens, movies, physical seats, shows, bookings, payments, and payment webhook events into related tables.

### Normalization

- **First Normal Form (1NF):** Each column stores a single value, and repeating groups are represented as separate rows.
- **Second Normal Form (2NF):** Non-key attributes depend on the full candidate key. Junction and transaction tables use explicit primary keys and appropriate unique constraints.
- **Third Normal Form (3NF):** Entity-specific attributes are stored in their relevant tables to reduce redundancy and update anomalies.
- **Boyce–Codd Normal Form (BCNF):** Each non-trivial functional dependency must have a determinant that is a superkey. BCNF compliance should be assessed against the documented functional dependencies and candidate keys of each table.

### Double-Booking Prevention

The `booking_seats` table contains the constraint:

```sql
UNIQUE (show_id, seat_id)
```

This prevents multiple booking-seat records for the same physical seat in the same show. The database rejects a duplicate insert with MySQL error 1062.

This constraint is a final integrity safeguard; it does not replace temporary seat holds or the booking transaction workflow.

### Indexing

Indexes support common lookup operations, including:

- Shows by theatre and date through the screen relationship and show-date indexes.
- Movie shows by movie and date.
- Bookings by customer and status.
- Seat bookings by show and seat.
- Expiring holds by status and expiry timestamp.
- Duplicate webhook-event detection by provider and event ID.

## P2 — List Shows for a Theatre and Date

The query in `sql/05_p2_queries.sql` joins `shows`, `screens`, `theatres`, and `movies`.

It returns the theatre name, city, movie title, language, screen name, show date, start time, end time, and ticket price.

Example parameters:

- Theatre ID: `1`
- Date: `2026-10-06`

The sample dataset returns the shows scheduled across the selected theatre's screens, ordered by start time.

## High-Concurrency Design

### Seat Holds

A production implementation can use Redis with atomic operations and a time-to-live (TTL) to temporarily reserve seats while a customer completes payment.

The hold workflow should:

1. Atomically acquire a hold for each requested seat.
2. Validate that the seat belongs to the requested show's screen.
3. Assign a unique hold token and expiry time.
4. Reject competing users while a valid hold exists.
5. Release expired holds automatically and clean up persistent hold records.
6. Validate hold ownership before converting a hold into a confirmed booking.

Redis holds and MySQL transactions must be coordinated carefully because they do not share a single transaction.

### Transactional Booking

The booking service should use MySQL transactions and appropriate row locking or conditional updates when confirming a booking. Database uniqueness constraints remain the final guard against duplicate seat records.

### Payment Idempotency

The `payment_webhook_events` table uses:

```sql
UNIQUE (provider, event_id)
```

A payment service should persist each provider event using this unique key and process the event and its booking-state changes transactionally. Duplicate deliveries must not confirm the same booking or apply the same payment twice.

Webhook signatures, valid payment status transitions, amount verification, and retry handling must also be implemented in the application layer.

## Testing

The SQL scripts support the following checks:

- Table and sample-data verification.
- P2 showtime query validation.
- Duplicate-seat detection.
- Unique-index inspection.
- Seat-hold expiry queries.
- Payment webhook uniqueness inspection.

The duplicate-seat test was verified against MySQL: attempting to insert an already-booked `(show_id, seat_id)` pair produced error 1062 as expected.

**Scope note:** The current deliverable is a database design and SQL implementation. Redis locking, automatic hold expiration, payment webhook processing, and a thousands-of-users load test require additional implementation and testing before they can be claimed as production-validated features.

## Future Improvements

- Implement a booking API with Redis-based seat holds.
- Add a background worker to release expired holds.
- Implement payment-provider webhook verification and idempotent processing.
- Add concurrent integration tests with multiple simulated users.
- Run load tests and record throughput, latency, and error rates.
- Analyze query plans using `EXPLAIN` and tune indexes based on measured workload.

## Author

**Udhaya Sankar**

GitHub: [udhayasa0507-stackly](https://github.com/udhayasa0507-stackly)

Repository: [bookmyshow-ticketing-system](https://github.com/udhayasa0507-stackly/bookmyshow-ticketing-system)
