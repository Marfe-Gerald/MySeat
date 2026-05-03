DELIMITER $$

-- Create Booking
DROP PROCEDURE IF EXISTS sp_CreateBooking$$
CREATE PROCEDURE sp_CreateBooking(
    IN  p_customerID  INT,
    IN  p_showtimeID  INT,
    IN  p_seatIDs     TEXT,
    OUT p_bookingID   INT,
    OUT p_message     VARCHAR(100)
)
BEGIN
    DECLARE v_seatID     INT;
    DECLARE v_ticketCode VARCHAR(20);
    DECLARE v_seatRow    VARCHAR(2);
    DECLARE v_seatNumber INT;
    DECLARE v_pos        INT;
    DECLARE v_remaining  TEXT;
    DECLARE v_current    VARCHAR(10);
    DECLARE v_valid      INT DEFAULT 1;

    -- Validate customer
    IF NOT EXISTS (SELECT 1 FROM tblCustomer WHERE customerID = p_customerID) THEN
        SET p_bookingID = 0;
        SET p_message   = 'Customer not found.';
        SET v_valid     = 0;
    END IF;

    -- Validate showtime
    IF v_valid = 1 AND NOT EXISTS (SELECT 1 FROM tblShowtime WHERE showtimeID = p_showtimeID) THEN
        SET p_bookingID = 0;
        SET p_message   = 'Showtime not found.';
        SET v_valid     = 0;
    END IF;

    IF v_valid = 1 THEN

        -- Create booking header
        INSERT INTO tblBooking (customerID, showtimeID, bookingStatus)
        VALUES (p_customerID, p_showtimeID, 'Confirmed');

        SET p_bookingID = LAST_INSERT_ID();

        -- Loop through comma-separated seatIDs
        SET v_remaining = p_seatIDs;

        WHILE LENGTH(v_remaining) > 0 DO
            SET v_pos = LOCATE(',', v_remaining);

            IF v_pos = 0 THEN
                SET v_current   = TRIM(v_remaining);
                SET v_remaining = '';
            ELSE
                SET v_current   = TRIM(SUBSTRING(v_remaining, 1, v_pos - 1));
                SET v_remaining = TRIM(SUBSTRING(v_remaining, v_pos + 1));
            END IF;

            SET v_seatID = CAST(v_current AS UNSIGNED);

            -- Get seat info for ticket code
            SELECT seatRow, seatNumber
            INTO v_seatRow, v_seatNumber
            FROM tblSeat WHERE seatID = v_seatID;

            -- Generate ticket code: TKT-{Row}{Number}-{Random 4 chars}
            SET v_ticketCode = CONCAT(
                'TKT-', v_seatRow, v_seatNumber, '-',
                UPPER(SUBSTRING(MD5(RAND()), 1, 4))
            );

            -- Insert ticket
            INSERT INTO tblTicket (bookingID, seatID, ticketCode, ticketStatus)
            VALUES (p_bookingID, v_seatID, v_ticketCode, 'Active');

        END WHILE;

        SET p_message = CONCAT('Booking created successfully. BookingID: ', p_bookingID);

    END IF;

END$$



-- Cancel Booking
DROP PROCEDURE IF EXISTS sp_CancelBooking$$
CREATE PROCEDURE sp_CancelBooking(
    IN  p_bookingID INT,
    OUT p_message   VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblBooking WHERE bookingID = p_bookingID) THEN
        SET p_message = 'Booking not found.';
    ELSEIF (SELECT bookingStatus FROM tblBooking
            WHERE bookingID = p_bookingID) = 'Cancelled' THEN
        SET p_message = 'Booking is already cancelled.';
    ELSE
        UPDATE tblTicket
        SET ticketStatus = 'Cancelled'
        WHERE bookingID = p_bookingID;

        UPDATE tblBooking
        SET bookingStatus = 'Cancelled'
        WHERE bookingID = p_bookingID;

        SET p_message = 'Booking cancelled successfully.';
    END IF;
END$$



-- Cancel Single Ticket
DROP PROCEDURE IF EXISTS sp_CancelTicket$$
CREATE PROCEDURE sp_CancelTicket(
    IN  p_ticketID INT,
    OUT p_message  VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblTicket WHERE ticketID = p_ticketID) THEN
        SET p_message = 'Ticket not found.';
    ELSEIF (SELECT ticketStatus FROM tblTicket
            WHERE ticketID = p_ticketID) = 'Cancelled' THEN
        SET p_message = 'Ticket is already cancelled.';
    ELSEIF (SELECT ticketStatus FROM tblTicket
            WHERE ticketID = p_ticketID) = 'Used' THEN
        SET p_message = 'Cannot cancel a used ticket.';
    ELSE
        UPDATE tblTicket
        SET ticketStatus = 'Cancelled'
        WHERE ticketID = p_ticketID;

        SET p_message = 'Ticket cancelled successfully.';
    END IF;
END$$


-- Use Ticket (scan at door)
DROP PROCEDURE IF EXISTS sp_UseTicket$$
CREATE PROCEDURE sp_UseTicket(
    IN  p_ticketCode VARCHAR(20),
    OUT p_message    VARCHAR(100)
)
BEGIN
    DECLARE v_ticketID     INT;
    DECLARE v_ticketStatus VARCHAR(20);

    SELECT ticketID, ticketStatus
    INTO v_ticketID, v_ticketStatus
    FROM tblTicket WHERE ticketCode = p_ticketCode;

    IF v_ticketID IS NULL THEN
        SET p_message = 'Ticket not found.';
    ELSEIF v_ticketStatus = 'Used' THEN
        SET p_message = 'Ticket has already been used.';
    ELSEIF v_ticketStatus = 'Cancelled' THEN
        SET p_message = 'Ticket is cancelled.';
    ELSE
        UPDATE tblTicket
        SET ticketStatus = 'Used'
        WHERE ticketID = v_ticketID;

        SET p_message = 'Ticket validated successfully.';
    END IF;
END$$

DELIMITER ;