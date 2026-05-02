-- view booking detials
CREATE OR REPLACE VIEW vw_BookingDetails AS
SELECT
    b.bookingID,
    b.bookingStatus,
    b.bookingTimestamp,
    c.customerID,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName,
    COUNT(t.ticketID) AS totalSeats
FROM tblBooking b
JOIN tblCustomer c   ON b.customerID  = c.customerID
JOIN tblShowtime sh  ON b.showtimeID  = sh.showtimeID
JOIN tblMovie m      ON sh.movieID    = m.movieID
JOIN tblCinema ci    ON sh.cinemaID   = ci.cinemaID
LEFT JOIN tblTicket t ON b.bookingID  = t.bookingID
GROUP BY b.bookingID;

-- view all bookings
CREATE OR REPLACE VIEW vw_AllBookings AS
SELECT
    b.bookingID,
    b.bookingStatus,
    b.bookingTimestamp,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName,
    COUNT(t.ticketID) AS totalSeats
FROM tblBooking b
JOIN tblCustomer c    ON b.customerID  = c.customerID
JOIN tblShowtime sh   ON b.showtimeID  = sh.showtimeID
JOIN tblMovie m       ON sh.movieID    = m.movieID
JOIN tblCinema ci     ON sh.cinemaID   = ci.cinemaID
LEFT JOIN tblTicket t ON b.bookingID   = t.bookingID
GROUP BY b.bookingID
ORDER BY b.bookingTimestamp DESC;

-- view confirmed bookings
CREATE OR REPLACE VIEW vw_ConfirmedBookings AS
SELECT
    b.bookingID,
    b.bookingTimestamp,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName,
    COUNT(t.ticketID) AS totalSeats
FROM tblBooking b
JOIN tblCustomer c    ON b.customerID  = c.customerID
JOIN tblShowtime sh   ON b.showtimeID  = sh.showtimeID
JOIN tblMovie m       ON sh.movieID    = m.movieID
JOIN tblCinema ci     ON sh.cinemaID   = ci.cinemaID
LEFT JOIN tblTicket t ON b.bookingID   = t.bookingID
WHERE b.bookingStatus = 'Confirmed'
GROUP BY b.bookingID;


-- view cancelled bookings
CREATE OR REPLACE VIEW vw_CancelledBookings AS
SELECT
    b.bookingID,
    b.bookingTimestamp,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName,
    COUNT(t.ticketID) AS seatsReleased
FROM tblBooking b
JOIN tblCustomer c    ON b.customerID  = c.customerID
JOIN tblShowtime sh   ON b.showtimeID  = sh.showtimeID
JOIN tblMovie m       ON sh.movieID    = m.movieID
JOIN tblCinema ci     ON sh.cinemaID   = ci.cinemaID
LEFT JOIN tblTicket t ON b.bookingID   = t.bookingID
WHERE b.bookingStatus = 'Cancelled'
GROUP BY b.bookingID;

-- view pending bookings
CREATE OR REPLACE VIEW vw_PendingBookings AS
SELECT
    b.bookingID,
    b.bookingTimestamp,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName,
    COUNT(t.ticketID) AS seatsHeld
FROM tblBooking b
JOIN tblCustomer c    ON b.customerID  = c.customerID
JOIN tblShowtime sh   ON b.showtimeID  = sh.showtimeID
JOIN tblMovie m       ON sh.movieID    = m.movieID
JOIN tblCinema ci     ON sh.cinemaID   = ci.cinemaID
LEFT JOIN tblTicket t ON b.bookingID   = t.bookingID
WHERE b.bookingStatus = 'Pending'
GROUP BY b.bookingID;

-- view booking per showtime

CREATE OR REPLACE VIEW vw_BookingPerShowtime AS
SELECT
    sh.showtimeID,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName,
    COUNT(DISTINCT b.bookingID)  AS totalBookings,
    COUNT(DISTINCT t.ticketID)   AS totalTicketsSold,
    COUNT(DISTINCT c.customerID) AS totalCustomers
FROM tblShowtime sh
JOIN tblMovie m      ON sh.movieID    = m.movieID
JOIN tblCinema ci    ON sh.cinemaID   = ci.cinemaID
LEFT JOIN tblBooking b  ON b.showtimeID = sh.showtimeID
    AND b.bookingStatus != 'Cancelled'
LEFT JOIN tblTicket t   ON t.bookingID  = b.bookingID
    AND t.ticketStatus  != 'Cancelled'
LEFT JOIN tblCustomer c ON b.customerID = c.customerID
GROUP BY sh.showtimeID;



-- view bookings made today
CREATE OR REPLACE VIEW vw_BookingSummaryToday AS
SELECT
    b.bookingID,
    b.bookingStatus,
    b.bookingTimestamp,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName,
    COUNT(t.ticketID) AS totalSeats
FROM tblBooking b
JOIN tblCustomer c    ON b.customerID  = c.customerID
JOIN tblShowtime sh   ON b.showtimeID  = sh.showtimeID
JOIN tblMovie m       ON sh.movieID    = m.movieID
JOIN tblCinema ci     ON sh.cinemaID   = ci.cinemaID
LEFT JOIN tblTicket t ON b.bookingID   = t.bookingID
WHERE DATE(b.bookingTimestamp) = CURDATE()
GROUP BY b.bookingID
ORDER BY b.bookingTimestamp DESC;