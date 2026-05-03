-- admin stored procedures

DELIMITER $$

-- Admin Login
DROP PROCEDURE IF EXISTS sp_AdminLogin$$
CREATE PROCEDURE sp_AdminLogin(
    IN  p_username     VARCHAR(50),
    IN  p_passwordHash VARCHAR(255),
    OUT p_adminID      INT,
    OUT p_message      VARCHAR(100)
)
BEGIN
    DECLARE v_adminID  INT;
    DECLARE v_isActive TINYINT;

    SELECT adminID, isActive
    INTO v_adminID, v_isActive
    FROM tblAdmin
    WHERE username     = p_username
    AND   passwordHash = p_passwordHash;

    IF v_adminID IS NULL THEN
        SET p_adminID = 0;
        SET p_message = 'Invalid username or password.';
    ELSEIF v_isActive = 0 THEN
        SET p_adminID = 0;
        SET p_message = 'Account is deactivated.';
    ELSE
        SET p_adminID = v_adminID;
        SET p_message = 'Login successful.';

        INSERT INTO tblAdminLog (adminID, actionType, remarks)
        VALUES (v_adminID, 'Login', 'Admin logged in.');
    END IF;
END$$

-- Admin Logout
DROP PROCEDURE IF EXISTS sp_AdminLogout$$
CREATE PROCEDURE sp_AdminLogout(
    IN  p_adminID INT,
    OUT p_message VARCHAR(100)
)
BEGIN
    IF NOT EXISTS (SELECT 1 FROM tblAdmin WHERE adminID = p_adminID) THEN
        SET p_message = 'Admin not found.';
    ELSE
        INSERT INTO tblAdminLog (adminID, actionType, remarks)
        VALUES (p_adminID, 'Logout', 'Admin logged out.');
        SET p_message = 'Logout successful.';
    END IF;
END$$

DELIMITER ;




