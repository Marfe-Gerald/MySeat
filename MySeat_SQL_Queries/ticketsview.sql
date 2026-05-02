-- view ticket details. used for printing or display after booking
CREATE OR REPLACE VIEW vw_TicketDetails AS
SELECT
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
    b.bookingID,
    b.bookingStatus,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName
FROM tblTicket t
JOIN tblBooking b    ON t.bookingID   = b.bookingID
JOIN tblSeat s       ON t.seatID      = s.seatID
JOIN tblCustomer c   ON b.customerID  = c.customerID
JOIN tblShowtime sh  ON b.showtimeID  = sh.showtimeID
JOIN tblMovie m      ON sh.movieID    = m.movieID
JOIN tblCinema ci    ON sh.cinemaID   = ci.cinemaID;

-- view active tickets only

CREATE OR REPLACE VIEW vw_ActiveTickets AS
SELECT
    t.ticketID,
    t.ticketCode,
    s.seatRow,
    s.seatNumber,
    s.zoneName,
    b.bookingID,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName
FROM tblTicket t
JOIN tblBooking b    ON t.bookingID   = b.bookingID
JOIN tblSeat s       ON t.seatID      = s.seatID
JOIN tblCustomer c   ON b.customerID  = c.customerID
JOIN tblShowtime sh  ON b.showtimeID  = sh.showtimeID
JOIN tblMovie m      ON sh.movieID    = m.movieID
JOIN tblCinema ci    ON sh.cinemaID   = ci.cinemaID
WHERE t.ticketStatus  = 'Active'
AND b.bookingStatus   = 'Confirmed';


-- view used tickets
CREATE OR REPLACE VIEW vw_UsedTickets AS
SELECT
    t.ticketID,
    t.ticketCode,
    s.seatRow,
    s.seatNumber,
    s.zoneName,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName
FROM tblTicket t
JOIN tblBooking b    ON t.bookingID   = b.bookingID
JOIN tblSeat s       ON t.seatID      = s.seatID
JOIN tblCustomer c   ON b.customerID  = c.customerID
JOIN tblShowtime sh  ON b.showtimeID  = sh.showtimeID
JOIN tblMovie m      ON sh.movieID    = m.movieID
JOIN tblCinema ci    ON sh.cinemaID   = ci.cinemaID
WHERE t.ticketStatus = 'Used';


-- view cancelled tickets
CREATE OR REPLACE VIEW vw_CancelledTickets AS
SELECT
    t.ticketID,
    t.ticketCode,
    s.seatRow,
    s.seatNumber,
    s.zoneName,
    b.bookingID,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName
FROM tblTicket t
JOIN tblBooking b    ON t.bookingID   = b.bookingID
JOIN tblSeat s       ON t.seatID      = s.seatID
JOIN tblCustomer c   ON b.customerID  = c.customerID
JOIN tblShowtime sh  ON b.showtimeID  = sh.showtimeID
JOIN tblMovie m      ON sh.movieID    = m.movieID
JOIN tblCinema ci    ON sh.cinemaID   = ci.cinemaID
WHERE t.ticketStatus = 'Cancelled';


-- view tickets per showtime
CREATE OR REPLACE VIEW vw_TicketsPerShowtime AS
SELECT
    sh.showtimeID,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName,
    COUNT(t.ticketID) AS totalTickets,
    SUM(CASE WHEN s.zoneName = 'Upper' THEN 1 ELSE 0 END) AS upperTickets,
    SUM(CASE WHEN s.zoneName = 'Lower' THEN 1 ELSE 0 END) AS lowerTickets
FROM tblShowtime sh
JOIN tblMovie m      ON sh.movieID    = m.movieID
JOIN tblCinema ci    ON sh.cinemaID   = ci.cinemaID
LEFT JOIN tblBooking b  ON b.showtimeID = sh.showtimeID
    AND b.bookingStatus != 'Cancelled'
LEFT JOIN tblTicket t   ON t.bookingID  = b.bookingID
    AND t.ticketStatus  != 'Cancelled'
LEFT JOIN tblSeat s     ON t.seatID     = s.seatID
GROUP BY sh.showtimeID;



-- view tickets under a booking id
CREATE OR REPLACE VIEW vw_TicketsByBooking AS
SELECT
    b.bookingID,
    b.bookingStatus,
    CONCAT(c.firstName, ' ', c.lastName) AS customerName,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName,
    GROUP_CONCAT(
        CONCAT(s.seatRow, s.seatNumber)
        ORDER BY s.seatRow, s.seatNumber
        SEPARATOR ', '
    ) AS seats,
    GROUP_CONCAT(
        t.ticketCode
        ORDER BY s.seatRow, s.seatNumber
        SEPARATOR ', '
    ) AS ticketCodes,
    COUNT(t.ticketID) AS totalTickets
FROM tblBooking b
JOIN tblCustomer c   ON b.customerID  = c.customerID
JOIN tblShowtime sh  ON b.showtimeID  = sh.showtimeID
JOIN tblMovie m      ON sh.movieID    = m.movieID
JOIN tblCinema ci    ON sh.cinemaID   = ci.cinemaID
JOIN tblTicket t     ON b.bookingID   = t.bookingID
JOIN tblSeat s       ON t.seatID      = s.seatID
GROUP BY b.bookingID;


