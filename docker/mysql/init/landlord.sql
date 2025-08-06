CREATE DATABASE IF NOT EXISTS landlord;

USE landlord;

-- Drop procedures if they exist
DROP PROCEDURE IF EXISTS create_tenant_db;

DELIMITER $$

-- Create tenant database and grant privileges
CREATE PROCEDURE create_tenant_db(
    IN dbname VARCHAR(64),
    IN dbuser VARCHAR(64)
)
BEGIN
    SET @query1 = CONCAT('CREATE DATABASE IF NOT EXISTS `', dbname, '` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci');
    PREPARE stmt1 FROM @query1;
    EXECUTE stmt1;
    DEALLOCATE PREPARE stmt1;

    SET @query2 = CONCAT('GRANT ALL PRIVILEGES ON `', dbname, '`.* TO ''', dbuser, '''@''%''');
    PREPARE stmt2 FROM @query2;
    EXECUTE stmt2;
    DEALLOCATE PREPARE stmt2;

    FLUSH PRIVILEGES;
END$$

DELIMITER ;
