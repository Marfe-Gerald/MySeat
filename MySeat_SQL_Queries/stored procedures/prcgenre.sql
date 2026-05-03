DELIMITER $$

-- Add Genre
DROP PROCEDURE IF EXISTS sp_AddGenre$$
CREATE PROCEDURE sp_AddGenre(
    IN  p_genreName VARCHAR(50),
    IN  p_adminID   INT,
    OUT p_genreID   INT,
    OUT p_message   VARCHAR(100)
)
BEGIN
    IF EXISTS (SELECT 1 FROM tblGenre WHERE genreName = p_genreName) THEN
        SET p_genreID = 0;
        SET p_message = 'Genre already exists.';
    ELSE
        INSERT INTO tblGenre (genreName) VALUES (p_genreName);

        SET p_genreID = LAST_INSERT_ID();

        INSERT INTO tblAdminLog (adminID, actionType, targetTable, targetID, remarks)
        VALUES (p_adminID, 'GenreAdded', 'tblGenre', p_genreID,
                CONCAT('Added genre: ', p_genreName));

        SET p_message = 'Genre added successfully.';
    END IF;
END$$


-- Assign Genre to Movie
DROP PROCEDURE IF EXISTS sp_AssignGenreToMovie$$
CREATE PROCEDURE sp_AssignGenreToMovie(
    IN  p_movieID INT,
    IN  p_genreID INT,
    IN  p_adminID INT,
    OUT p_message VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblMovie WHERE movieID = p_movieID) THEN
        SET p_message = 'Movie not found.';
    ELSEIF NOT EXISTS (SELECT 1 FROM tblGenre WHERE genreID = p_genreID) THEN
        SET p_message = 'Genre not found.';
    ELSEIF EXISTS (SELECT 1 FROM tblMovieGenre
                   WHERE movieID = p_movieID AND genreID = p_genreID) THEN
        SET p_message = 'Genre already assigned to this movie.';
    ELSE
        INSERT INTO tblMovieGenre (movieID, genreID)
        VALUES (p_movieID, p_genreID);

        INSERT INTO tblAdminLog (adminID, actionType, targetTable, targetID, remarks)
        VALUES (p_adminID, 'MovieEdited', 'tblMovieGenre', p_movieID,
                CONCAT('Assigned genreID ', p_genreID, ' to movieID ', p_movieID));

        SET p_message = 'Genre assigned successfully.';
    END IF;
END$$


-- Remove Genre from Movie
DROP PROCEDURE IF EXISTS sp_RemoveGenreFromMovie$$
CREATE PROCEDURE sp_RemoveGenreFromMovie(
    IN  p_movieID INT,
    IN  p_genreID INT,
    IN  p_adminID INT,
    OUT p_message VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblMovieGenre
                   WHERE movieID = p_movieID AND genreID = p_genreID) THEN
        SET p_message = 'Genre not assigned to this movie.';
    ELSE
        DELETE FROM tblMovieGenre
        WHERE movieID = p_movieID AND genreID = p_genreID;

        INSERT INTO tblAdminLog (adminID, actionType, targetTable, targetID, remarks)
        VALUES (p_adminID, 'MovieEdited', 'tblMovieGenre', p_movieID,
                CONCAT('Removed genreID ', p_genreID, ' from movieID ', p_movieID));

        SET p_message = 'Genre removed successfully.';
    END IF;
END$$

DELIMITER ;