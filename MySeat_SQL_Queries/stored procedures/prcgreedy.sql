DELIMITER $$

-- Get Available Seats By Row (feeds the greedy algorithm)
DROP PROCEDURE IF EXISTS sp_GetAvailableSeatsByRow$$
CREATE PROCEDURE sp_GetAvailableSeatsByRow(
    IN p_showtimeID INT,
    IN p_zoneName   VARCHAR(20)
)
BEGIN
    SELECT
        s.seatRow,
        s.zoneName,
        COUNT(s.seatID) AS totalSeats,
        SUM(CASE WHEN ts.seatID IS NULL THEN 1 ELSE 0 END) AS availableSeats,
        GROUP_CONCAT(
            CASE WHEN ts.seatID IS NULL THEN s.seatID END
            ORDER BY s.seatNumber
        ) AS availableSeatIDs
    FROM tblSeat s
    LEFT JOIN vw_TakenSeats ts ON s.seatID     = ts.seatID
        AND ts.showtimeID = p_showtimeID
    JOIN tblShowtime sh        ON sh.showtimeID = p_showtimeID
        AND sh.cinemaID = s.cinemaID
    WHERE s.zoneName = p_zoneName
    GROUP BY s.seatRow, s.zoneName
    ORDER BY s.seatRow;
END$$


-- Greedy Allocate Seats (main greedy algorithm)
DROP PROCEDURE IF EXISTS sp_GreedyAllocateSeats$$
CREATE PROCEDURE sp_GreedyAllocateSeats(
    IN  p_showtimeID INT,
    IN  p_zoneName   VARCHAR(20),
    IN  p_seatCount  INT,
    OUT p_seatIDs    TEXT,
    OUT p_strategy   VARCHAR(50),
    OUT p_message    VARCHAR(255)
)
BEGIN
    DECLARE v_seatRow        VARCHAR(2);
    DECLARE v_availableSeats INT;
    DECLARE v_seatIDs        TEXT;
    DECLARE v_collected      TEXT DEFAULT '';
    DECLARE v_collectedCount INT  DEFAULT 0;
    DECLARE v_done           INT  DEFAULT 0;
    DECLARE v_valid          INT  DEFAULT 1;

    -- Cursor: rows ordered by most available seats (greedy scoring)
    DECLARE row_cursor CURSOR FOR
        SELECT
            s.seatRow,
            SUM(CASE WHEN ts.seatID IS NULL THEN 1 ELSE 0 END) AS availableSeats,
            GROUP_CONCAT(
                CASE WHEN ts.seatID IS NULL THEN s.seatID END
                ORDER BY s.seatNumber
            ) AS availableSeatIDs
        FROM tblSeat s
        LEFT JOIN vw_TakenSeats ts ON s.seatID     = ts.seatID
            AND ts.showtimeID = p_showtimeID
        JOIN tblShowtime sh        ON sh.showtimeID = p_showtimeID
            AND sh.cinemaID = s.cinemaID
        WHERE s.zoneName = p_zoneName
        GROUP BY s.seatRow
        HAVING availableSeats > 0
        ORDER BY availableSeats DESC, s.seatRow ASC;

    DECLARE CONTINUE HANDLER FOR NOT FOUND SET v_done = 1;

    -- STEP 1: Try to find a single row with enough contiguous seats
    SELECT
        GROUP_CONCAT(s.seatID ORDER BY s.seatNumber) AS seatIDs
    INTO v_seatIDs
    FROM tblSeat s
    LEFT JOIN vw_TakenSeats ts ON s.seatID     = ts.seatID
        AND ts.showtimeID = p_showtimeID
    JOIN tblShowtime sh        ON sh.showtimeID = p_showtimeID
        AND sh.cinemaID = s.cinemaID
    WHERE s.zoneName  = p_zoneName
    AND   ts.seatID   IS NULL
    GROUP BY s.seatRow
    HAVING COUNT(s.seatID) >= p_seatCount
    ORDER BY ABS(AVG(s.seatNumber) - 8.5) ASC
    LIMIT 1;

    -- If contiguous block found in one row
    IF v_seatIDs IS NOT NULL THEN
        SET p_seatIDs  = v_seatIDs;
        SET p_strategy = 'Contiguous Single Row';
        SET p_message  = CONCAT('Found ', p_seatCount,
                                ' contiguous seats in one row.');
        SET v_valid    = 0;  -- skip Step 2
    END IF;

    -- STEP 2: Greedy scatter — collect from best rows
    IF v_valid = 1 THEN

        OPEN row_cursor;

        read_loop: LOOP
            FETCH row_cursor INTO v_seatRow, v_availableSeats, v_seatIDs;

            IF v_done = 1 OR v_collectedCount >= p_seatCount THEN
                LEAVE read_loop;
            END IF;

            -- Take as many as needed from this row
            IF v_collectedCount + v_availableSeats >= p_seatCount THEN
                SET v_collected = CONCAT_WS(',', v_collected,
                    SUBSTRING_INDEX(v_seatIDs, ',', p_seatCount - v_collectedCount));
                SET v_collectedCount = p_seatCount;
            ELSE
                SET v_collected      = CONCAT_WS(',', v_collected, v_seatIDs);
                SET v_collectedCount = v_collectedCount + v_availableSeats;
            END IF;

        END LOOP;

        CLOSE row_cursor;

        IF v_collectedCount >= p_seatCount THEN
            SET p_seatIDs  = v_collected;
            SET p_strategy = 'Scatter Multi Row';
            SET p_message  = CONCAT('Allocated ', p_seatCount,
                                    ' seats across multiple rows.');
        ELSE
            SET p_seatIDs  = v_collected;
            SET p_strategy = 'Partial';
            SET p_message  = CONCAT('Only ', v_collectedCount, ' of ',
                                    p_seatCount, ' seats available in zone.');
        END IF;

    END IF;

END$$

DELIMITER ;