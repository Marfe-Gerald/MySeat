DELIMITER $$

-- Add Movie
DROP PROCEDURE IF EXISTS sp_AddMovie$$
CREATE PROCEDURE sp_AddMovie(
    IN  p_title    VARCHAR(100),
    IN  p_duration VARCHAR(20),
    IN  p_rating   VARCHAR(10),
    IN  p_adminID  INT,
    OUT p_movieID  INT,
    OUT p_message  VARCHAR(100)
)
BEGIN
    INSERT INTO tblMovie (title, duration, rating)
    VALUES (p_title, p_duration, p_rating);

    SET p_movieID = LAST_INSERT_ID();

    INSERT INTO tblAdminLog (adminID, actionType, targetTable, targetID, remarks)
    VALUES (p_adminID, 'MovieAdded', 'tblMovie', p_movieID,
            CONCAT('Added movie: ', p_title));

    SET p_message = 'Movie added successfully.';
END$$



-- Edit Movie
DROP PROCEDURE IF EXISTS sp_EditMovie$$
CREATE PROCEDURE sp_EditMovie(
    IN  p_movieID  INT,
    IN  p_title    VARCHAR(100),
    IN  p_duration VARCHAR(20),
    IN  p_rating   VARCHAR(10),
    IN  p_adminID  INT,
    OUT p_message  VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblMovie WHERE movieID = p_movieID) THEN
        SET p_message = 'Movie not found.';
    ELSE
        UPDATE tblMovie
        SET title    = p_title,
            duration = p_duration,
            rating   = p_rating
        WHERE movieID = p_movieID;

        INSERT INTO tblAdminLog (adminID, actionType, targetTable, targetID, remarks)
        VALUES (p_adminID, 'MovieEdited', 'tblMovie', p_movieID,
                CONCAT('Edited movie: ', p_title));

        SET p_message = 'Movie updated successfully.';
    END IF;
END$$


-- Delete Movie
DROP PROCEDURE IF EXISTS sp_DeleteMovie$$
CREATE PROCEDURE sp_DeleteMovie(
    IN  p_movieID INT,
    IN  p_adminID INT,
    OUT p_message VARCHAR(100)
)
BEGIN
    DECLARE v_title VARCHAR(100);

    SELECT title INTO v_title
    FROM tblMovie WHERE movieID = p_movieID;

    IF v_title IS NULL THEN
        SET p_message = 'Movie not found.';
    ELSE
        DELETE FROM tblMovie WHERE movieID = p_movieID;

        INSERT INTO tblAdminLog (adminID, actionType, targetTable, targetID, remarks)
        VALUES (p_adminID, 'MovieDeleted', 'tblMovie', p_movieID,
                CONCAT('Deleted movie: ', v_title));

        SET p_message = 'Movie deleted successfully.';
    END IF;
END$$

DELIMITER ;