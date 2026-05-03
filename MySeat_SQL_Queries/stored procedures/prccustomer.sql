DELIMITER $$
-- Register Customer
DROP PROCEDURE IF EXISTS sp_RegisterCustomer$$
CREATE PROCEDURE sp_RegisterCustomer(
    IN  p_lastName   VARCHAR(50),
    IN  p_firstName  VARCHAR(50),
    IN  p_middleName VARCHAR(50),
    OUT p_customerID INT,
    OUT p_message    VARCHAR(100)
)
BEGIN
    INSERT INTO tblCustomer (lastName, firstName, middleName)
    VALUES (p_lastName, p_firstName, p_middleName);

    SET p_customerID = LAST_INSERT_ID();
    SET p_message    = 'Customer registered successfully.';
END$$

DELIMITER ;