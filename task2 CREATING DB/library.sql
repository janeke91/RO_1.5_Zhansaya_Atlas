CREATE DATABASE IF NOT EXISTS library_physical_db;
USE library_physical_db;

SET FOREIGN_KEY_CHECKS = 0;
DROP TABLE IF EXISTS RESERVATIONS, FINES, LOANS, LIBRARY_STAFF, BORROWERS, CATALOG, BOOK_AUTHORS, BOOKS, AUTHORS, GENRES;
SET FOREIGN_KEY_CHECKS = 1;

CREATE TABLE GENRES (
genre_id INT AUTO_INCREMENT PRIMARY KEY,
genre_name VARCHAR(50) NOT NULL UNIQUE );

CREATE TABLE AUTHORS (
author_id INT AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL, 
birth_date DATE,
nationality VARCHAR(30) );

CREATE TABLE BOOKS (
book_id INT AUTO_INCREMENT PRIMARY KEY,
title VARCHAR(200) NOT NULL,
isbn VARCHAR(20) UNIQUE NOT NULL,
year_published INT,
genre_id INT,
CONSTRAINT fk_book_genre FOREIGN KEY (genre_id) REFERENCES GENRES(genre_id) );

CREATE TABLE BOOK_AUTHORS (
book_id INT,
author_id INT,
PRIMARY KEY (book_id, author_id),
CONSTRAINT fk_ba_book FOREIGN KEY (book_id) REFERENCES BOOKS(book_id) ON DELETE CASCADE,
CONSTRAINT fk_ba_author FOREIGN KEY (author_id) REFERENCES AUTHORS(author_id) ON DELETE CASCADE );

CREATE TABLE CATALOG (
catalog_id INT AUTO_INCREMENT PRIMARY KEY,
book_id INT,
shelf_location VARCHAR(20) NOT NULL,
section VARCHAR(30), 
status VARCHAR(20) NOT NULL DEFAULT 'Available',
CONSTRAINT check_status CHECK (status IN ('Available', 'Loaned', 'Reserved')),
CONSTRAINT fk_catalog_book FOREIGN KEY (book_id) REFERENCES BOOKS(book_id) );

CREATE TABLE BORROWERS (
borrower_id INT AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
email VARCHAR(100) UNIQUE NOT NULL,
phone VARCHAR(20), 
address VARCHAR(100), 
registration_date DATE NOT NULL CHECK (registration_date > '2026-01-01') );

CREATE TABLE LIBRARY_STAFF (
staff_id INT AUTO_INCREMENT PRIMARY KEY,
first_name VARCHAR(50) NOT NULL,
last_name VARCHAR(50) NOT NULL,
email VARCHAR(50), 
phone VARCHAR(20), 
iin VARCHAR(12) UNIQUE NOT NULL CHECK (LENGTH(iin) = 12),
role VARCHAR(40) DEFAULT 'Librarian',
hire_date DATE NOT NULL  );

CREATE TABLE LOANS (
loan_id INT AUTO_INCREMENT PRIMARY KEY,
catalog_id INT,
borrower_id INT,
staff_id INT,
loan_date DATE DEFAULT (CURRENT_DATE),
due_date DATE NOT NULL,
return_date DATE, 
CONSTRAINT check_loan_dates CHECK (due_date >= loan_date),
CONSTRAINT fk_loan_catalog FOREIGN KEY (catalog_id) REFERENCES CATALOG(catalog_id),
CONSTRAINT fk_loan_borrower FOREIGN KEY (borrower_id) REFERENCES BORROWERS(borrower_id),
CONSTRAINT fk_loan_staff FOREIGN KEY (staff_id) REFERENCES LIBRARY_STAFF(staff_id) );

CREATE TABLE FINES (
fine_id INT AUTO_INCREMENT PRIMARY KEY,
loan_id INT UNIQUE,
amount DECIMAL(10,2) NOT NULL DEFAULT 0.00 CHECK (amount >= 0),
paid_date DATE, 
status VARCHAR(20) NOT NULL,
CONSTRAINT fk_fine_loan FOREIGN KEY (loan_id) REFERENCES LOANS(loan_id) );

CREATE TABLE RESERVATIONS (
reservation_id INT AUTO_INCREMENT PRIMARY KEY,
book_id INT,
borrower_id INT,
reservation_date DATE NOT NULL,
status VARCHAR(20) NOT NULL,
res_type VARCHAR(20) NOT NULL CHECK (res_type IN ('Online', 'Physical')), -- МІНЕ, ОСЫ БАҒАН ЖЕТІСПЕДІ
CONSTRAINT fk_res_book FOREIGN KEY (book_id) REFERENCES BOOKS(book_id),
CONSTRAINT fk_res_borrower FOREIGN KEY (borrower_id) REFERENCES BORROWERS(borrower_id)
);

ALTER TABLE GENRES ADD COLUMN record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE AUTHORS ADD COLUMN record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE BOOKS ADD COLUMN record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE BOOK_AUTHORS ADD COLUMN record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE CATALOG ADD COLUMN record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE BORROWERS ADD COLUMN record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE LIBRARY_STAFF ADD COLUMN record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE LOANS ADD COLUMN record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE FINES ADD COLUMN record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP;
ALTER TABLE RESERVATIONS ADD COLUMN record_ts TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- +-20ст
INSERT INTO GENRES (genre_name) VALUES 
('Classic'), ('Fantasy'), ('Science Fiction'), ('Mystery'), ('History'), ('Biography');

INSERT INTO AUTHORS (first_name, last_name, birth_date, nationality) VALUES 
('Abai', 'Kunanbayuly', '1845-08-10', 'Kazakh'), 
('Mukhtar', 'Auezov', '1897-09-28', 'Kazakh'), 
('J.K.', 'Rowling', '1965-07-31', 'British'), 
('George', 'Orwell', '1903-06-25', 'British'), 
('Stephen', 'Hawking', '1942-01-08', 'British'), 
('Walter', 'Isaacson', '1952-05-20', 'American');

INSERT INTO BOOKS (title, isbn, year_published, genre_id) VALUES 
('The Book of Words', '978-0001', 1890, 1),
('The Path of Abai', '978-0002', 1942, 1), 
('Harry Potter', '978-0003', 1997, 2),      
('1984', '978-0004', 1949, 3),              
('A Brief History of Time', '978-0005', 1988, 5), 
('Steve Jobs', '978-0006', 2011, 6);        

INSERT INTO BOOK_AUTHORS (book_id, author_id) VALUES 
(1, 1), (2, 2), (3, 3), (4, 4), (5, 5), (6, 6);

INSERT INTO CATALOG (book_id, shelf_location, section, status) VALUES 
(1, 'A-10', 'Kazakh Literature', 'Available'), 
(1, 'A-11', 'Kazakh Literature', 'Loaned'),
(2, 'A-20', 'Kazakh Literature', 'Available'), 
(3, 'B-01', 'Foreign Fiction', 'Reserved'),
(4, 'C-05', 'Political Classics', 'Available'), 
(5, 'D-01', 'Science Sector', 'Loaned'),
(6, 'E-12', 'Biography Section', 'Available'), 
(3, 'B-02', 'Foreign Fiction', 'Available');

INSERT INTO BORROWERS (first_name, last_name, email, phone, address, registration_date) VALUES 
('Arman', 'Sabit', 'arman.s@mail.kz', '+77011112233', 'Atyrau, Satpayev 15', '2026-02-10'),
('Aliya', 'Serik', 'aliya.s@mail.kz', '+77025556677', 'Atyrau, Azattyk 20', '2026-03-05'),
('Asel', 'Bolat', 'asel.b@mail.kz', '+77778889900', 'Atyrau, Lomonosov 5', '2026-04-12'),
('Dulat', 'Asan', 'dulat.a@mail.kz', '+77054443322', 'Atyrau, Makhambet 10', '2026-05-20');

INSERT INTO LIBRARY_STAFF (first_name, last_name, email, phone, iin, role, hire_date) VALUES 
('Ivan', 'Ivanov', 'ivan.i@lib.kz', '+77001234567', '123456789012', 'Manager', '2026-01-10'),
('Serik', 'Kuan', 'serik.k@lib.kz', '+77009876543', '987654321098', 'Librarian', '2026-01-15'),
('Aigul', 'Daulet', 'aigul.d@lib.kz', '+77005554433', '456789123456', 'Assistant', '2026-02-01');

INSERT INTO LOANS (catalog_id, borrower_id, staff_id, due_date, return_date) VALUES 
(2, 1, 1, '2026-06-01', NULL), 
(6, 2, 2, '2026-06-15', '2026-06-14'),
(5, 3, 2, '2026-07-01', NULL),
(1, 4, 1, '2026-07-20', NULL);

INSERT INTO FINES (loan_id, amount, paid_date, status) VALUES 
(1, 1200.50, NULL, 'Unpaid'), 
(2, 0.00, '2026-06-14', 'Paid');

INSERT INTO RESERVATIONS (book_id, borrower_id, reservation_date, status, res_type) VALUES 
(3, 1, '2026-05-25', 'Active', 'Online'), 
(1, 3, '2026-05-26', 'Completed', 'Physical');