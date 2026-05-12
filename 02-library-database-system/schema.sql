-- Day 2 - Library Database System
-- PostgreSQL schema

-- Drop child tables first because they depend on parent tables through foreign keys.
DROP TABLE IF EXISTS borrow_records;
DROP TABLE IF EXISTS books;
DROP TABLE IF EXISTS members;
DROP TABLE IF EXISTS authors;

CREATE TABLE authors (
    author_id SERIAL PRIMARY KEY,
    author_name VARCHAR(100) NOT NULL UNIQUE,
    country VARCHAR(60),
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE books (
    book_id SERIAL PRIMARY KEY,
    title VARCHAR(150) NOT NULL,
    author_id INTEGER NOT NULL,
    category VARCHAR(60) NOT NULL,
    published_year INTEGER,
    total_copies INTEGER NOT NULL DEFAULT 1,
    available_copies INTEGER NOT NULL DEFAULT 1,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_books_author
        FOREIGN KEY (author_id)
        REFERENCES authors (author_id),

    CONSTRAINT uq_books_title_author
        UNIQUE (title, author_id),

    CONSTRAINT chk_books_published_year
        CHECK (published_year IS NULL OR published_year BETWEEN 1000 AND 2100),

    CONSTRAINT chk_books_total_copies
        CHECK (total_copies >= 0),

    CONSTRAINT chk_books_available_copies
        CHECK (available_copies >= 0),

    CONSTRAINT chk_books_available_not_more_than_total
        CHECK (available_copies <= total_copies)
);

CREATE TABLE members (
    member_id SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    phone_number VARCHAR(30) UNIQUE,
    city VARCHAR(60) NOT NULL,
    membership_date DATE NOT NULL DEFAULT CURRENT_DATE,
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP
);

-- The borrow_records table stores library activity over time.
-- One member can borrow many books, and one book can be borrowed many times.
CREATE TABLE borrow_records (
    borrow_id SERIAL PRIMARY KEY,
    member_id INTEGER NOT NULL,
    book_id INTEGER NOT NULL,
    borrow_date DATE NOT NULL,
    due_date DATE NOT NULL,
    return_date DATE,
    status VARCHAR(20) NOT NULL DEFAULT 'borrowed',
    created_at TIMESTAMPTZ NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT fk_borrow_records_member
        FOREIGN KEY (member_id)
        REFERENCES members (member_id),

    CONSTRAINT fk_borrow_records_book
        FOREIGN KEY (book_id)
        REFERENCES books (book_id),

    CONSTRAINT chk_borrow_records_status
        CHECK (status IN ('borrowed', 'returned', 'overdue')),

    CONSTRAINT chk_borrow_records_due_date
        CHECK (due_date >= borrow_date),

    CONSTRAINT chk_borrow_records_return_date
        CHECK (return_date IS NULL OR return_date >= borrow_date),

    -- Returned records should have a return date.
    -- Borrowed and overdue records are still open, so return_date should be NULL.
    CONSTRAINT chk_borrow_records_return_logic
        CHECK (
            (status = 'returned' AND return_date IS NOT NULL)
            OR
            (status IN ('borrowed', 'overdue') AND return_date IS NULL)
        )
);
