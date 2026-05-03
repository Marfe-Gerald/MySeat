DELIMITER $$

-- Add Showtime
DROP PROCEDURE IF EXISTS sp_AddShowtime$$
CREATE PROCEDURE sp_AddShowtime(
    IN  p_movieID    INT,
    IN  p_cinemaID   INT,
    IN  p_showDate   DATE,
    IN  p_startTime  TIME,
    IN  p_adminID    INT,
    OUT p_showtimeID INT,
    OUT p_message    VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblMovie WHERE movieID = p_movieID) THEN
        SET p_showtimeID = 0;
        SET p_message    = 'Movie not found.';
    ELSEIF NOT EXISTS (SELECT 1 FROM tblCinema WHERE cinemaID = p_cinemaID) THEN
        SET p_showtimeID = 0;
        SET p_message    = 'Cinema not found.';
    ELSEIF EXISTS (
        SELECT 1 FROM tblShowtime
        WHERE cinemaID  = p_cinemaID
        AND   showDate  = p_showDate
        AND   startTime = p_startTime
    ) THEN
        SET p_showtimeID = 0;
        SET p_message    = 'A showtime already exists at this time in this cinema.';
    ELSE
        INSERT INTO tblShowtime (movieID, cinemaID, showDate, startTime)
        VALUES (p_movieID, p_cinemaID, p_showDate, p_startTime);

        SET p_showtimeID = LAST_INSERT_ID();

        INSERT INTO tblAdminLog (adminID, actionType, targetTable, targetID, remarks)
        VALUES (p_adminID, 'ShowtimeAdded', 'tblShowtime', p_showtimeID,
                CONCAT('Added showtime on ', p_showDate, ' at ', p_startTime));

        SET p_message = 'Showtime added successfully.';
    END IF;
END$$


-- Edit Showtime
DROP PROCEDURE IF EXISTS sp_EditShowtime$$
CREATE PROCEDURE sp_EditShowtime(
    IN  p_showtimeID INT,
    IN  p_showDate   DATE,
    IN  p_startTime  TIME,
    IN  p_adminID    INT,
    OUT p_message    VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblShowtime WHERE showtimeID = p_showtimeID) THEN
        SET p_message = 'Showtime not found.';
    ELSE
        UPDATE tblShowtime
        SET showDate  = p_showDate,
            startTime = p_startTime
        WHERE showtimeID = p_showtimeID;

        INSERT INTO tblAdminLog (adminID, actionType, targetTable, targetID, remarks)
        VALUES (p_adminID, 'ShowtimeEdited', 'tblShowtime', p_showtimeID,
                CONCAT('Updated to ', p_showDate, ' at ', p_startTime));

        SET p_message = 'Showtime updated successfully.';
    END IF;
END$$


-- Delete Showtime
DROP PROCEDURE IF EXISTS sp_DeleteShowtime$$
CREATE PROCEDURE sp_DeleteShowtime(
    IN  p_showtimeID INT,
    IN  p_adminID    INT,
    OUT p_message    VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblShowtime WHERE showtimeID = p_showtimeID) THEN
        SET p_message = 'Showtime not found.';
    ELSE
        DELETE FROM tblShowtime WHERE showtimeID = p_showtimeID;

        INSERT INTO tblAdminLog (adminID, actionType, targetTable, targetID, remarks)
        VALUES (p_adminID, 'ShowtimeDeleted', 'tblShowtime', p_showtimeID,
                CONCAT('Deleted showtimeID: ', p_showtimeID));

        SET p_message = 'Showtime deleted successfully.';
    END IF;
END$$

DELIMITER ;