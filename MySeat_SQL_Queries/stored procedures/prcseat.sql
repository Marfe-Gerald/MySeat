DELIMITER $$

-- Add Seat
DROP PROCEDURE IF EXISTS sp_AddSeat$$
CREATE PROCEDURE sp_AddSeat(
    IN  p_cinemaID   INT,
    IN  p_seatRow    VARCHAR(2),
    IN  p_seatNumber INT,
    IN  p_zoneName   VARCHAR(20),
    IN  p_adminID    INT,
    OUT p_seatID     INT,
    OUT p_message    VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblCinema WHERE cinemaID = p_cinemaID) THEN
        SET p_seatID  = 0;
        SET p_message = 'Cinema not found.';
    ELSEIF EXISTS (
        SELECT 1 FROM tblSeat
        WHERE cinemaID   = p_cinemaID
        AND   seatRow    = p_seatRow
        AND   seatNumber = p_seatNumber
    ) THEN
        SET p_seatID  = 0;
        SET p_message = 'Seat already exists.';
    ELSE
        INSERT INTO tblSeat (cinemaID, seatRow, seatNumber, zoneName)
        VALUES (p_cinemaID, p_seatRow, p_seatNumber, p_zoneName);

        SET p_seatID = LAST_INSERT_ID();

        INSERT INTO tblAdminLog (adminID, actionType, targetTable, targetID, remarks)
        VALUES (p_adminID, 'SeatAdded', 'tblSeat', p_seatID,
                CONCAT('Added seat ', p_seatRow, p_seatNumber, ' in cinemaID ', p_cinemaID));

        SET p_message = 'Seat added successfully.';
    END IF;
END$$


-- Edit Seat
DROP PROCEDURE IF EXISTS sp_EditSeat$$
CREATE PROCEDURE sp_EditSeat(
    IN  p_seatID     INT,
    IN  p_seatRow    VARCHAR(2),
    IN  p_seatNumber INT,
    IN  p_zoneName   VARCHAR(20),
    IN  p_adminID    INT,
    OUT p_message    VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblSeat WHERE seatID = p_seatID) THEN
        SET p_message = 'Seat not found.';
    ELSE
        UPDATE tblSeat
        SET seatRow    = p_seatRow,
            seatNumber = p_seatNumber,
            zoneName   = p_zoneName
        WHERE seatID = p_seatID;

        INSERT INTO tblAdminLog (adminID, actionType, targetTable, targetID, remarks)
        VALUES (p_adminID, 'SeatEdited', 'tblSeat', p_seatID,
                CONCAT('Edited seat to ', p_seatRow, p_seatNumber));

        SET p_message = 'Seat updated successfully.';
    END IF;
END$$



-- Delete Seat
DROP PROCEDURE IF EXISTS sp_DeleteSeat$$
CREATE PROCEDURE sp_DeleteSeat(
    IN  p_seatID  INT,
    IN  p_adminID INT,
    OUT p_message VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblSeat WHERE seatID = p_seatID) THEN
        SET p_message = 'Seat not found.';
    ELSE
        DELETE FROM tblSeat WHERE seatID = p_seatID;

        INSERT INTO tblAdminLog (adminID, actionType, targetTable, targetID, remarks)
        VALUES (p_adminID, 'SeatDeleted', 'tblSeat', p_seatID,
                CONCAT('Deleted seatID: ', p_seatID));

        SET p_message = 'Seat deleted successfully.';
    END IF;
END$$

DELIMITER ;