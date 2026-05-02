-- view movie details
CREATE OR REPLACE VIEW vw_MovieDetails AS
SELECT
    m.movieID,
    m.title,
    m.duration,
    m.rating,
    GROUP_CONCAT(g.genreName ORDER BY g.genreName SEPARATOR ', ') AS genres
FROM tblMovie m
LEFT JOIN tblMovieGenre mg ON m.movieID  = mg.movieID
LEFT JOIN tblGenre g       ON mg.genreID = g.genreID
GROUP BY m.movieID;

-- view movies now showing
CREATE OR REPLACE VIEW vw_MoviesNowShowing AS
SELECT DISTINCT
    m.movieID,
    m.title,
    m.duration,
    m.rating,
    GROUP_CONCAT(DISTINCT g.genreName ORDER BY g.genreName SEPARATOR ', ') AS genres
FROM tblMovie m
JOIN tblShowtime sh        ON m.movieID   = sh.movieID
LEFT JOIN tblMovieGenre mg ON m.movieID   = mg.movieID
LEFT JOIN tblGenre g       ON mg.genreID  = g.genreID
WHERE sh.showDate >= CURDATE()
GROUP BY m.movieID;

-- view movie sched
CREATE OR REPLACE VIEW vw_MovieSchedule AS
SELECT
    m.movieID,
    m.title,
    m.duration,
    m.rating,
    GROUP_CONCAT(DISTINCT g.genreName ORDER BY g.genreName SEPARATOR ', ') AS genres,
    ci.cinemaName,
    sh.showtimeID,
    sh.showDate,
    sh.startTime
FROM tblMovie m
JOIN tblShowtime sh         ON m.movieID   = sh.movieID
JOIN tblCinema ci           ON sh.cinemaID = ci.cinemaID
LEFT JOIN tblMovieGenre mg  ON m.movieID   = mg.movieID
LEFT JOIN tblGenre g        ON mg.genreID  = g.genreID
GROUP BY m.movieID, sh.showtimeID;


-- view cinema details
CREATE OR REPLACE VIEW vw_CinemaDetails AS
SELECT
    ci.cinemaID,
    ci.cinemaName,
    COUNT(s.seatID) AS totalSeats,
    SUM(CASE WHEN s.zoneName = 'Upper' THEN 1 ELSE 0 END) AS upperSeats,
    SUM(CASE WHEN s.zoneName = 'Lower' THEN 1 ELSE 0 END) AS lowerSeats
FROM tblCinema ci
LEFT JOIN tblSeat s ON ci.cinemaID = s.cinemaID
GROUP BY ci.cinemaID;

-- view cinema showtimes
CREATE OR REPLACE VIEW vw_CinemaShowtimes AS
SELECT
    ci.cinemaID,
    ci.cinemaName,
    sh.showtimeID,
    m.title AS movie,
    m.duration,
    m.rating,
    sh.showDate,
    sh.startTime
FROM tblCinema ci
JOIN tblShowtime sh ON ci.cinemaID = sh.cinemaID
JOIN tblMovie m     ON sh.movieID  = m.movieID
ORDER BY ci.cinemaID, sh.showDate, sh.startTime;


-- view movie genres
CREATE OR REPLACE VIEW vw_MovieGenreList AS
SELECT
    m.movieID,
    m.title,
    g.genreID,
    g.genreName
FROM tblMovie m
LEFT JOIN tblMovieGenre mg ON m.movieID  = mg.movieID
LEFT JOIN tblGenre g       ON mg.genreID = g.genreID
ORDER BY m.title, g.genreName;

-- view cinema occupancy today
CREATE OR REPLACE VIEW vw_CinemaOccupancyToday AS
SELECT
    ci.cinemaID,
    ci.cinemaName,
    sh.showtimeID,
    sh.startTime,
    m.title AS movie,
    COUNT(DISTINCT s.seatID) AS totalSeats,
    COUNT(DISTINCT tk.ticketID) AS takenSeats,
    ROUND((COUNT(DISTINCT tk.ticketID) / COUNT(DISTINCT s.seatID)) * 100, 1) AS occupancyPercent
FROM tblCinema ci
JOIN tblShowtime sh   ON ci.cinemaID  = sh.cinemaID
JOIN tblMovie m       ON sh.movieID   = m.movieID
JOIN tblSeat s        ON s.cinemaID   = ci.cinemaID
LEFT JOIN tblBooking b  ON b.showtimeID = sh.showtimeID
    AND b.bookingStatus != 'Cancelled'
LEFT JOIN tblTicket tk  ON tk.bookingID = b.bookingID
    AND tk.seatID = s.seatID
    AND tk.ticketStatus != 'Cancelled'
WHERE sh.showDate = CURDATE()
GROUP BY ci.cinemaID, sh.showtimeID;

-- view available seats per cinema per showtime
CREATE OR REPLACE VIEW vw_CinemaAvailableSeats AS
SELECT
    ci.cinemaID,
    ci.cinemaName,
    s.seatID,
    s.seatRow,
    s.seatNumber,
    s.zoneName,
    CASE
        WHEN s.seatNumber <= 8 THEN 'Left'
        ELSE 'Right'
    END AS seatSection,
    sh.showtimeID,
    sh.showDate,
    sh.startTime
FROM tblCinema ci
JOIN tblSeat s       ON ci.cinemaID  = s.cinemaID
CROSS JOIN tblShowtime sh
WHERE s.cinemaID = sh.cinemaID
AND s.seatID NOT IN (
    SELECT seatID FROM vw_TakenSeats
    WHERE showtimeID = sh.showtimeID
)
ORDER BY ci.cinemaID, sh.showtimeID, s.seatRow, s.seatNumber;

-- view movie booking summary
CREATE OR REPLACE VIEW vw_MovieBookingSummary AS
SELECT
    m.movieID,
    m.title,
    COUNT(DISTINCT b.bookingID)  AS totalBookings,
    COUNT(DISTINCT tk.ticketID)  AS totalTicketsSold,
    COUNT(DISTINCT sh.showtimeID) AS totalShowtimes
FROM tblMovie m
LEFT JOIN tblShowtime sh ON m.movieID     = sh.movieID
LEFT JOIN tblBooking b   ON sh.showtimeID = b.showtimeID
    AND b.bookingStatus != 'Cancelled'
LEFT JOIN tblTicket tk   ON b.bookingID   = tk.bookingID
    AND tk.ticketStatus != 'Cancelled'
GROUP BY m.movieID;
