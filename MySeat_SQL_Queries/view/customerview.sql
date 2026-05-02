-- view bookings made by each customer
CREATE OR REPLACE VIEW vw_CustomerBookingHistory AS
SELECT
    c.customerID,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    b.bookingID,
    b.bookingStatus,
    b.bookingTimestamp,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName,
    COUNT(t.ticketID) AS seatsBooked
FROM tblCustomer c
JOIN tblBooking b    ON c.customerID  = b.customerID
JOIN tblShowtime sh  ON b.showtimeID  = sh.showtimeID
JOIN tblMovie m      ON sh.movieID    = m.movieID
JOIN tblCinema ci    ON sh.cinemaID   = ci.cinemaID
LEFT JOIN tblTicket t ON b.bookingID  = t.bookingID
GROUP BY b.bookingID;


-- view tickets belonging to a customer
CREATE OR REPLACE VIEW vw_CustomerTickets AS
SELECT
    c.customerID,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    b.bookingID,
    t.ticketID,
    t.ticketCode,
    t.ticketStatus,
    s.seatRow,
    s.seatNumber,
    s.zoneName,
    CASE
        WHEN s.seatNumber <= 8 THEN 'Left'
        ELSE 'Right'
    END AS seatSection,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName
FROM tblCustomer c
JOIN tblBooking b    ON c.customerID  = b.customerID
JOIN tblTicket t     ON b.bookingID   = t.bookingID
JOIN tblSeat s       ON t.seatID      = s.seatID
JOIN tblShowtime sh  ON b.showtimeID  = sh.showtimeID
JOIN tblMovie m      ON sh.movieID    = m.movieID
JOIN tblCinema ci    ON sh.cinemaID   = ci.cinemaID;

-- view customer summary
CREATE OR REPLACE VIEW vw_CustomerSummary AS
SELECT
    c.customerID,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    c.lastName,
    c.firstName,
    c.middleName,
    COUNT(DISTINCT b.bookingID) AS totalBookings,
    COUNT(DISTINCT t.ticketID)  AS totalTickets,
    SUM(CASE WHEN b.bookingStatus = 'Cancelled' THEN 1 ELSE 0 END) AS cancelledBookings,
    SUM(CASE WHEN b.bookingStatus = 'Confirmed' THEN 1 ELSE 0 END) AS confirmedBookings
FROM tblCustomer c
LEFT JOIN tblBooking b ON c.customerID = b.customerID
LEFT JOIN tblTicket t  ON b.bookingID  = t.bookingID
    AND t.ticketStatus != 'Cancelled'
GROUP BY c.customerID;

-- view customer active bookings (confirmed and pending)
CREATE OR REPLACE VIEW vw_CustomerActiveBookings AS
SELECT
    c.customerID,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    b.bookingID,
    b.bookingStatus,
    b.bookingTimestamp,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName,
    COUNT(t.ticketID) AS seatsBooked
FROM tblCustomer c
JOIN tblBooking b     ON c.customerID  = b.customerID
JOIN tblShowtime sh   ON b.showtimeID  = sh.showtimeID
JOIN tblMovie m       ON sh.movieID    = m.movieID
JOIN tblCinema ci     ON sh.cinemaID   = ci.cinemaID
LEFT JOIN tblTicket t ON b.bookingID   = t.bookingID
WHERE b.bookingStatus IN ('Confirmed', 'Pending')
GROUP BY b.bookingID;

-- view cancelled bookings 
CREATE OR REPLACE VIEW vw_CustomerCancelledBookings AS
SELECT
    c.customerID,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    b.bookingID,
    b.bookingTimestamp,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName,
    COUNT(t.ticketID) AS seatsReleased
FROM tblCustomer c
JOIN tblBooking b     ON c.customerID  = b.customerID
JOIN tblShowtime sh   ON b.showtimeID  = sh.showtimeID
JOIN tblMovie m       ON sh.movieID    = m.movieID
JOIN tblCinema ci     ON sh.cinemaID   = ci.cinemaID
LEFT JOIN tblTicket t ON b.bookingID   = t.bookingID
WHERE b.bookingStatus = 'Cancelled'
GROUP BY b.bookingID;