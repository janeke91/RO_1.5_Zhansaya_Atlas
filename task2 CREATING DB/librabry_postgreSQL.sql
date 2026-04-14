DROP TABLE IF EXISTS reservations, fines, loans, library_staff, borrowers, catalog, book_authors, books, authors, genres CASCADE;


CREATE TABLE genres (
    genre_id   SERIAL PRIMARY KEY,
    genre_name VARCHAR(50) NOT NULL UNIQUE,
    record_ts  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE authors (
    author_id   SERIAL PRIMARY KEY,
    first_name  VARCHAR(50) NOT NULL,
    last_name   VARCHAR(50) NOT NULL,
    birth_date  DATE,
    nationality VARCHAR(30),
    record_ts   TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE books (
    book_id        SERIAL PRIMARY KEY,
    title          VARCHAR(200) NOT NULL,
    isbn           VARCHAR(20)  UNIQUE NOT NULL,
    year_published INT,
    genre_id       INT,
    record_ts      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_book_genre FOREIGN KEY (genre_id) REFERENCES genres(genre_id)
);


CREATE TABLE book_authors (
    book_id   INT,
    author_id INT,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (book_id, author_id),
    CONSTRAINT fk_ba_book   FOREIGN KEY (book_id)   REFERENCES books(book_id)   ON DELETE CASCADE,
    CONSTRAINT fk_ba_author FOREIGN KEY (author_id) REFERENCES authors(author_id) ON DELETE CASCADE
);


CREATE TABLE catalog (
    catalog_id     SERIAL PRIMARY KEY,
    book_id        INT,
    shelf_location VARCHAR(20) NOT NULL,
    section        VARCHAR(30),
    status         VARCHAR(20) NOT NULL DEFAULT 'Available',
    record_ts      TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_status      CHECK (status IN ('Available', 'Loaned', 'Reserved')),
    CONSTRAINT fk_catalog_book   FOREIGN KEY (book_id) REFERENCES books(book_id)
);


CREATE TABLE borrowers (
    borrower_id       SERIAL PRIMARY KEY,
    first_name        VARCHAR(50)  NOT NULL,
    last_name         VARCHAR(50)  NOT NULL,
    email             VARCHAR(100) UNIQUE NOT NULL,
    phone             VARCHAR(20),
    address           VARCHAR(100),
    registration_date DATE NOT NULL CHECK (registration_date > '2026-01-01'),
    record_ts         TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE library_staff (
    staff_id   SERIAL PRIMARY KEY,
    first_name VARCHAR(50) NOT NULL,
    last_name  VARCHAR(50) NOT NULL,
    email      VARCHAR(50),
    phone      VARCHAR(20),
    iin        VARCHAR(12) UNIQUE NOT NULL CHECK (LENGTH(iin) = 12),
    role       VARCHAR(40) DEFAULT 'Librarian',
    hire_date  DATE NOT NULL,
    record_ts  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);


CREATE TABLE loans (
    loan_id     SERIAL PRIMARY KEY,
    catalog_id  INT,
    borrower_id INT,
    staff_id    INT,
    loan_date   DATE NOT NULL DEFAULT CURRENT_DATE,
    due_date    DATE NOT NULL,
    return_date DATE,
    record_ts   TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT check_loan_dates  CHECK (due_date >= loan_date),
    CONSTRAINT fk_loan_catalog   FOREIGN KEY (catalog_id)  REFERENCES catalog(catalog_id),
    CONSTRAINT fk_loan_borrower  FOREIGN KEY (borrower_id) REFERENCES borrowers(borrower_id),
    CONSTRAINT fk_loan_staff     FOREIGN KEY (staff_id)    REFERENCES library_staff(staff_id)
);


CREATE TABLE fines (
    fine_id   SERIAL PRIMARY KEY,
    loan_id   INT UNIQUE,
    amount    NUMERIC(10,2) NOT NULL DEFAULT 0.00 CHECK (amount >= 0),
    paid_date DATE,
    status    VARCHAR(20) NOT NULL,
    record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_fine_loan FOREIGN KEY (loan_id) REFERENCES loans(loan_id)
);


CREATE TABLE reservations (
    reservation_id   SERIAL PRIMARY KEY,
    book_id          INT,
    borrower_id      INT,
    reservation_date DATE NOT NULL,
    status           VARCHAR(20) NOT NULL,
    res_type         VARCHAR(20) NOT NULL CHECK (res_type IN ('Online', 'Physical')),
    record_ts        TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_res_book     FOREIGN KEY (book_id)     REFERENCES books(book_id),
    CONSTRAINT fk_res_borrower FOREIGN KEY (borrower_id) REFERENCES borrowers(borrower_id)
);


INSERT INTO genres (genre_name) VALUES
    ('Classic'), ('Fantasy'), ('Science Fiction'),
    ('Mystery'), ('History'), ('Biography');

INSERT INTO authors (first_name, last_name, birth_date, nationality) VALUES
    ('Abai',    'Kunanbayuly', '1845-08-10', 'Kazakh'),
    ('Mukhtar', 'Auezov',     '1897-09-28', 'Kazakh'),
    ('J.K.',    'Rowling',    '1965-07-31', 'British'),
    ('George',  'Orwell',     '1903-06-25', 'British'),
    ('Stephen', 'Hawking',    '1942-01-08', 'British'),
    ('Walter',  'Isaacson',   '1952-05-20', 'American');

INSERT INTO books (title, isbn, year_published, genre_id) VALUES
    ('The Book of Words',        '978-0001', 1890, 1),
    ('The Path of Abai',         '978-0002', 1942, 1),
    ('Harry Potter',             '978-0003', 1997, 2),
    ('1984',                     '978-0004', 1949, 3),
    ('A Brief History of Time',  '978-0005', 1988, 5),
    ('Steve Jobs',               '978-0006', 2011, 6);

INSERT INTO book_authors (book_id, author_id) VALUES
    (1,1),(2,2),(3,3),(4,4),(5,5),(6,6);

INSERT INTO catalog (book_id, shelf_location, section, status) VALUES
    (1, 'A-10', 'Kazakh Literature',  'Available'),
    (1, 'A-11', 'Kazakh Literature',  'Loaned'),
    (2, 'A-20', 'Kazakh Literature',  'Available'),
    (3, 'B-01', 'Foreign Fiction',    'Reserved'),
    (4, 'C-05', 'Political Classics', 'Available'),
    (5, 'D-01', 'Science Sector',     'Loaned'),
    (6, 'E-12', 'Biography Section',  'Available'),
    (3, 'B-02', 'Foreign Fiction',    'Available');

INSERT INTO borrowers (first_name, last_name, email, phone, address, registration_date) VALUES
    ('Arman', 'Sabit', 'arman.s@mail.kz', '+77011112233', 'Atyrau, Satpayev 15',  '2026-02-10'),
    ('Aliya', 'Serik', 'aliya.s@mail.kz', '+77025556677', 'Atyrau, Azattyk 20',   '2026-03-05'),
    ('Asel',  'Bolat', 'asel.b@mail.kz',  '+77778889900', 'Atyrau, Lomonosov 5',  '2026-04-12'),
    ('Dulat', 'Asan',  'dulat.a@mail.kz', '+77054443322', 'Atyrau, Makhambet 10', '2026-05-20');

INSERT INTO library_staff (first_name, last_name, email, phone, iin, role, hire_date) VALUES
    ('Ivan',  'Ivanov', 'ivan.i@lib.kz',  '+77001234567', '123456789012', 'Manager',   '2026-01-10'),
    ('Serik', 'Kuan',   'serik.k@lib.kz', '+77009876543', '987654321098', 'Librarian', '2026-01-15'),
    ('Aigul', 'Daulet', 'aigul.d@lib.kz', '+77005554433', '456789123456', 'Assistant', '2026-02-01');

INSERT INTO loans (catalog_id, borrower_id, staff_id, due_date, return_date) VALUES
    (2, 1, 1, '2026-06-01', NULL),
    (6, 2, 2, '2026-06-15', '2026-06-14'),
    (5, 3, 2, '2026-07-01', NULL),
    (1, 4, 1, '2026-07-20', NULL);

INSERT INTO fines (loan_id, amount, paid_date, status) VALUES
    (1, 1200.50, NULL,         'Unpaid'),
    (2,    0.00, '2026-06-14', 'Paid');

INSERT INTO reservations (book_id, borrower_id, reservation_date, status, res_type) VALUES
    (3, 1, '2026-05-25', 'Active',    'Online'),
    (1, 3, '2026-05-26', 'Completed', 'Physical');
