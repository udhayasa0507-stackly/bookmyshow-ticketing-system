
USE bookmyshow_ticketing;

CREATE TABLE users (
    user_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    full_name VARCHAR(100) NOT NULL,
    email VARCHAR(255) NOT NULL,
    phone VARCHAR(20),
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT uq_users_email UNIQUE (email)
) ENGINE=InnoDB;


CREATE TABLE theatres (
    theatre_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    theatre_name VARCHAR(150) NOT NULL,
    city VARCHAR(100) NOT NULL,
    address VARCHAR(255) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    INDEX idx_theatres_city (city)
) ENGINE=InnoDB;


CREATE TABLE screens (
    screen_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    theatre_id BIGINT UNSIGNED NOT NULL,
    screen_name VARCHAR(100) NOT NULL,
    CONSTRAINT fk_screens_theatre
        FOREIGN KEY (theatre_id) REFERENCES theatres(theatre_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_screen_theatre_name UNIQUE (theatre_id, screen_name)
) ENGINE=InnoDB;


CREATE TABLE movies (
    movie_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    title VARCHAR(200) NOT NULL,
    language VARCHAR(50) NOT NULL,
    duration_minutes SMALLINT UNSIGNED NOT NULL,
    certificate VARCHAR(20),
    release_date DATE,
    INDEX idx_movies_title (title)
) ENGINE=InnoDB;

CREATE TABLE seats (
    seat_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    screen_id BIGINT UNSIGNED NOT NULL,
    row_label VARCHAR(10) NOT NULL,
    seat_number SMALLINT UNSIGNED NOT NULL,
    seat_type ENUM('REGULAR', 'PREMIUM', 'RECLINER')
        NOT NULL DEFAULT 'REGULAR',
    CONSTRAINT fk_seats_screen
        FOREIGN KEY (screen_id) REFERENCES screens(screen_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_seat_position
        UNIQUE (screen_id, row_label, seat_number)
) ENGINE=InnoDB;

CREATE TABLE shows (
    show_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    movie_id BIGINT UNSIGNED NOT NULL,
    screen_id BIGINT UNSIGNED NOT NULL,
    show_date DATE NOT NULL,
    start_time TIME NOT NULL,
    end_time TIME NOT NULL,
    language VARCHAR(50) NOT NULL,
    ticket_price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_shows_movie
        FOREIGN KEY (movie_id) REFERENCES movies(movie_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_shows_screen
        FOREIGN KEY (screen_id) REFERENCES screens(screen_id)
        ON DELETE RESTRICT,
    CONSTRAINT chk_show_time CHECK (end_time > start_time),
    CONSTRAINT chk_ticket_price CHECK (ticket_price >= 0),
    INDEX idx_shows_screen_date (screen_id, show_date),
    INDEX idx_shows_date_time (show_date, start_time),
    INDEX idx_shows_movie_date (movie_id, show_date)
) ENGINE=InnoDB;

CREATE TABLE bookings (
    booking_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT UNSIGNED NOT NULL,
    show_id BIGINT UNSIGNED NOT NULL,
    booking_reference VARCHAR(50) NOT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'CANCELLED', 'EXPIRED')
        NOT NULL DEFAULT 'PENDING',
    total_amount DECIMAL(10,2) NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    expires_at TIMESTAMP NULL,
    confirmed_at TIMESTAMP NULL,
    CONSTRAINT fk_bookings_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_bookings_show
        FOREIGN KEY (show_id) REFERENCES shows(show_id)
        ON DELETE RESTRICT,
    CONSTRAINT uq_booking_reference UNIQUE (booking_reference),
    CONSTRAINT chk_booking_amount CHECK (total_amount >= 0),
    INDEX idx_bookings_user (user_id),
    INDEX idx_bookings_show_status (show_id, status),
    INDEX idx_bookings_expiry (status, expires_at)
) ENGINE=InnoDB;

CREATE TABLE booking_seats (
    booking_seat_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT UNSIGNED NOT NULL,
    show_id BIGINT UNSIGNED NOT NULL,
    seat_id BIGINT UNSIGNED NOT NULL,
    price DECIMAL(10,2) NOT NULL,
    CONSTRAINT fk_booking_seats_booking
        FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_booking_seats_show
        FOREIGN KEY (show_id) REFERENCES shows(show_id)
        ON DELETE RESTRICT,
    CONSTRAINT fk_booking_seats_seat
        FOREIGN KEY (seat_id) REFERENCES seats(seat_id)
        ON DELETE RESTRICT,
    CONSTRAINT uq_show_seat UNIQUE (show_id, seat_id),
    CONSTRAINT chk_booking_seat_price CHECK (price >= 0),
    INDEX idx_booking_seats_booking (booking_id)
) ENGINE=InnoDB;

CREATE TABLE payments (
    payment_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    booking_id BIGINT UNSIGNED NOT NULL,
    provider VARCHAR(50) NOT NULL,
    provider_payment_id VARCHAR(150) NOT NULL,
    amount DECIMAL(10,2) NOT NULL,
    status ENUM('PENDING', 'SUCCESS', 'FAILED', 'REFUNDED')
        NOT NULL DEFAULT 'PENDING',
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP
        ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_payments_booking
        FOREIGN KEY (booking_id) REFERENCES bookings(booking_id)
        ON DELETE RESTRICT,
    CONSTRAINT uq_provider_payment UNIQUE (provider, provider_payment_id),
    CONSTRAINT chk_payment_amount CHECK (amount >= 0),
    INDEX idx_payments_booking (booking_id)
) ENGINE=InnoDB;

CREATE TABLE payment_webhook_events (
    webhook_event_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    provider VARCHAR(50) NOT NULL,
    event_id VARCHAR(150) NOT NULL,
    event_type VARCHAR(100) NOT NULL,
    payload JSON NOT NULL,
    processed BOOLEAN NOT NULL DEFAULT FALSE,
    received_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    processed_at TIMESTAMP NULL,
    CONSTRAINT uq_webhook_provider_event UNIQUE (provider, event_id),
    INDEX idx_webhook_processed (processed, received_at)
) ENGINE=InnoDB;

CREATE TABLE seat_holds (
    hold_id BIGINT UNSIGNED AUTO_INCREMENT PRIMARY KEY,
    show_id BIGINT UNSIGNED NOT NULL,
    seat_id BIGINT UNSIGNED NOT NULL,
    user_id BIGINT UNSIGNED NOT NULL,
    hold_token VARCHAR(100) NOT NULL,
    status ENUM('ACTIVE', 'RELEASED', 'CONVERTED', 'EXPIRED')
        NOT NULL DEFAULT 'ACTIVE',
    expires_at TIMESTAMP NOT NULL,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_holds_show
        FOREIGN KEY (show_id) REFERENCES shows(show_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_holds_seat
        FOREIGN KEY (seat_id) REFERENCES seats(seat_id)
        ON DELETE CASCADE,
    CONSTRAINT fk_holds_user
        FOREIGN KEY (user_id) REFERENCES users(user_id)
        ON DELETE CASCADE,
    CONSTRAINT uq_hold_token UNIQUE (hold_token),
    INDEX idx_holds_show_seat (show_id, seat_id),
    INDEX idx_holds_expiry (status, expires_at)
) ENGINE=InnoDB;
