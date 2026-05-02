-- view admin
CREATE OR REPLACE VIEW vw_AdminActivityLog AS
SELECT
    al.logID,
    CONCAT(a.firstName, ' ', a.lastName) AS adminName,
    al.actionType,
    al.targetTable,
    al.targetID,
    al.actionTimestamp,
    al.remarks
FROM tblAdminLog al
JOIN tblAdmin a ON al.adminID = a.adminID
ORDER BY al.actionTimestamp DESC;

-- view admin login and logout transactions
CREATE OR REPLACE VIEW vw_AdminLoginHistory AS
SELECT
    al.logID,
    a.adminID,
    CONCAT(a.firstName, ' ', a.lastName) AS adminName,
    al.actionType,
    al.actionTimestamp,
    al.remarks
FROM tblAdminLog al
JOIN tblAdmin a ON al.adminID = a.adminID
WHERE al.actionType IN ('Login', 'Logout')
ORDER BY al.actionTimestamp DESC;

-- view movie-related actions
CREATE OR REPLACE VIEW vw_AdminMovieActions AS
SELECT
    al.logID,
    CONCAT(a.firstName, ' ', a.lastName) AS adminName,
    al.actionType,
    al.targetID AS movieID,
    m.title AS movieTitle,
    al.actionTimestamp,
    al.remarks
FROM tblAdminLog al
JOIN tblAdmin a        ON al.adminID   = a.adminID
LEFT JOIN tblMovie m   ON al.targetID  = m.movieID
WHERE al.actionType IN ('MovieAdded', 'MovieEdited', 'MovieDeleted')
ORDER BY al.actionTimestamp DESC;


-- view showtime-related actions
CREATE OR REPLACE VIEW vw_AdminShowtimeActions AS
SELECT
    al.logID,
    CONCAT(a.firstName, ' ', a.lastName) AS adminName,
    al.actionType,
    al.targetID AS showtimeID,
    sh.showDate,
    sh.startTime,
    al.actionTimestamp,
    al.remarks
FROM tblAdminLog al
JOIN tblAdmin a             ON al.adminID  = a.adminID
LEFT JOIN tblShowtime sh    ON al.targetID = sh.showtimeID
WHERE al.actionType IN ('ShowtimeAdded', 'ShowtimeEdited', 'ShowtimeDeleted')
ORDER BY al.actionTimestamp DESC;

-- view seat-related actions
CREATE OR REPLACE VIEW vw_AdminSeatActions AS
SELECT
    al.logID,
    CONCAT(a.firstName, ' ', a.lastName) AS adminName,
    al.actionType,
    al.targetID AS seatID,
    s.seatRow,
    s.seatNumber,
    s.zoneName,
    al.actionTimestamp,
    al.remarks
FROM tblAdminLog al
JOIN tblAdmin a          ON al.adminID  = a.adminID
LEFT JOIN tblSeat s      ON al.targetID = s.seatID
WHERE al.actionType IN ('SeatAdded', 'SeatEdited', 'SeatDeleted')
ORDER BY al.actionTimestamp DESC;


-- view genre-related actions
CREATE OR REPLACE VIEW vw_AdminGenreActions AS
SELECT
    al.logID,
    CONCAT(a.firstName, ' ', a.lastName) AS adminName,
    al.actionType,
    al.targetID AS genreID,
    g.genreName,
    al.actionTimestamp,
    al.remarks
FROM tblAdminLog al
JOIN tblAdmin a          ON al.adminID  = a.adminID
LEFT JOIN tblGenre g     ON al.targetID = g.genreID
WHERE al.actionType IN ('GenreAdded', 'GenreEdited', 'GenreDeleted')
ORDER BY al.actionTimestamp DESC;


-- view admin summary
CREATE OR REPLACE VIEW vw_AdminSummary AS
SELECT
    a.adminID,
    CONCAT(a.firstName, ' ', a.lastName) AS adminName,
    a.username,
    a.isActive,
    COUNT(al.logID) AS totalActions,
    MAX(CASE WHEN al.actionType = 'Login' THEN al.actionTimestamp END) AS lastLogin,
    MAX(al.actionTimestamp) AS lastActivity
FROM tblAdmin a
LEFT JOIN tblAdminLog al ON a.adminID = al.adminID
GROUP BY a.adminID;