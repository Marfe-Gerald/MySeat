-- view taken seats
CREATE OR REPLACE VIEW vw_TakenSeats AS
    SELECT
        tk.seatID,
        bk.showtimeID,
        tk.ticketCode,
        tk.ticketStatus
    FROM tblTicket tk
    JOIN tblBooking bk ON tk.bookingID = bk.bookingID
    WHERE tk.ticketStatus != 'Cancelled'
      AND bk.bookingStatus != 'Cancelled';
   
     
-- view available seats
CREATE VIEW vw_AvailableSeats AS
SELECT s.seatID, s.seatRow, s.seatNumber, s.zoneName, st.showtimeID
FROM tblSeat s
CROSS JOIN tblShowtime st
WHERE s.cinemaID = st.cinemaID
AND s.seatID NOT IN (
    SELECT seatID FROM vw_TakenSeats
    WHERE showtimeID = st.showtimeID
);



-- seat occupancy per showtime
CREATE OR REPLACE VIEW vw_SeatOccupancyPerShowtime AS
SELECT
    sh.showtimeID,
    m.title AS movie,
    sh.showDate,
    sh.startTime,
    ci.cinemaName,
    COUNT(DISTINCT s.seatID) AS totalSeats,
    COUNT(DISTINCT tk.ticketID) AS takenSeats,
    COUNT(DISTINCT s.seatID) - COUNT(DISTINCT tk.ticketID) AS availableSeats,
    ROUND((COUNT(DISTINCT tk.ticketID) / COUNT(DISTINCT s.seatID)) * 100, 1) AS occupancyPercent
FROM tblShowtime sh
JOIN tblMovie m       ON sh.movieID  = m.movieID
JOIN tblCinema ci     ON sh.cinemaID = ci.cinemaID
JOIN tblSeat s        ON s.cinemaID  = ci.cinemaID
LEFT JOIN tblBooking b  ON b.showtimeID = sh.showtimeID
    AND b.bookingStatus != 'Cancelled'
LEFT JOIN tblTicket tk  ON tk.bookingID = b.bookingID
    AND tk.seatID = s.seatID
    AND tk.ticketStatus != 'Cancelled'
GROUP BY sh.showtimeID;



-- Seat occupancy by zone
CREATE OR REPLACE VIEW vw_SeatOccupancyPerZone AS
SELECT
    sh.showtimeID,
    s.zoneName,
    COUNT(DISTINCT s.seatID) AS totalSeats,
    COUNT(DISTINCT tk.ticketID) AS takenSeats,
    COUNT(DISTINCT s.seatID) - COUNT(DISTINCT tk.ticketID) AS availableSeats
FROM tblShowtime sh
JOIN tblCinema ci     ON sh.cinemaID = ci.cinemaID
JOIN tblSeat s        ON s.cinemaID  = ci.cinemaID
LEFT JOIN tblBooking b  ON b.showtimeID = sh.showtimeID
    AND b.bookingStatus != 'Cancelled'
LEFT JOIN tblTicket tk  ON tk.bookingID = b.bookingID
    AND tk.seatID = s.seatID
    AND tk.ticketStatus != 'Cancelled'
GROUP BY sh.showtimeID, s.zoneName;




-- Tickets By Zone
CREATE OR REPLACE VIEW vw_TicketsByZone AS
SELECT
    b.showtimeID,
    s.zoneName,
    COUNT(t.ticketID) AS ticketsSold
FROM tblTicket t
JOIN tblSeat s    ON t.seatID    = s.seatID
JOIN tblBooking b ON t.bookingID = b.bookingID
WHERE t.ticketStatus != 'Cancelled'
AND b.bookingStatus  != 'Cancelled'
GROUP BY b.showtimeID, s.zoneName;



-- Seat Details
CREATE OR REPLACE VIEW vw_SeatDetails AS
SELECT
    s.seatID,
    s.seatRow,
    s.seatNumber,
    s.zoneName,
    s.cinemaID,
    sh.showtimeID,
    CASE
        WHEN tk.ticketStatus = 'Active'    THEN 'Taken'
        WHEN tk.ticketStatus = 'Used'      THEN 'Used'
        WHEN tk.ticketStatus = 'Cancelled' THEN 'Available'
        ELSE 'Available'
    END AS seatStatus
FROM tblSeat s
CROSS JOIN tblShowtime sh
LEFT JOIN tblTicket tk  ON s.seatID     = tk.seatID
LEFT JOIN tblBooking b  ON tk.bookingID = b.bookingID
    AND b.showtimeID    = sh.showtimeID
    AND b.bookingStatus != 'Cancelled'
WHERE s.cinemaID = sh.cinemaID;

-- view available seats by row
CREATE OR REPLACE VIEW vw_SeatsByRow AS
SELECT
    s.seatRow,
    s.zoneName,
    sh.showtimeID,
    COUNT(s.seatID) AS totalSeats,
    SUM(CASE WHEN ts.seatID IS NULL THEN 1 ELSE 0 END) AS availableSeats,
    GROUP_CONCAT(
        CASE WHEN ts.seatID IS NULL THEN s.seatID END
        ORDER BY s.seatNumber
    ) AS availableSeatIDs
FROM tblSeat s
CROSS JOIN tblShowtime sh
LEFT JOIN vw_TakenSeats ts ON s.seatID = ts.seatID
    AND ts.showtimeID = sh.showtimeID
WHERE s.cinemaID = sh.cinemaID
GROUP BY s.seatRow, s.zoneName, sh.showtimeID;


-- view longest run of consecutive available seats per row per showtime
CREATE OR REPLACE VIEW vw_ContiguousSeats AS
SELECT
    s.seatRow,
    s.zoneName,
    sh.showtimeID,
    COUNT(s.seatID) AS consecutiveAvailable,
    MIN(s.seatNumber) AS startSeat,
    MAX(s.seatNumber) AS endSeat
FROM tblSeat s
CROSS JOIN tblShowtime sh
LEFT JOIN vw_TakenSeats ts ON s.seatID = ts.seatID
    AND ts.showtimeID = sh.showtimeID
WHERE s.cinemaID = sh.cinemaID
AND ts.seatID IS NULL
GROUP BY s.seatRow, s.zoneName, sh.showtimeID;

