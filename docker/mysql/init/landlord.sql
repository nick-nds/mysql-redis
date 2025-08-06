-- Landlord database for multi-tenant management
CREATE DATABASE IF NOT EXISTS landlord CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;

USE landlord;

-- Table to track all tenants
CREATE TABLE IF NOT EXISTS tenants (
    id INT AUTO_INCREMENT PRIMARY KEY,
    tenant_code VARCHAR(64) NOT NULL UNIQUE,
    database_name VARCHAR(64) NOT NULL UNIQUE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('active', 'suspended', 'deleted') DEFAULT 'active',
    INDEX idx_status (status),
    INDEX idx_tenant_code (tenant_code)
) ENGINE=InnoDB;

-- Drop existing procedure
DROP PROCEDURE IF EXISTS create_tenant_database;

DELIMITER $$

-- Procedure to create a tenant database when a tenant is created
CREATE PROCEDURE create_tenant_database(
    IN p_tenant_code VARCHAR(64)
)
BEGIN
    DECLARE v_db_name VARCHAR(64);
    
    -- Validate input
    IF p_tenant_code IS NULL OR p_tenant_code = '' THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tenant code cannot be empty';
    END IF;
    
    -- Generate database name (prefix with 'tenant_')
    SET v_db_name = CONCAT('tenant_', LOWER(REPLACE(REPLACE(p_tenant_code, '-', '_'), ' ', '_')));
    
    -- Create database
    SET @sql = CONCAT('CREATE DATABASE IF NOT EXISTS `', v_db_name, '` CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    -- Grant privileges to app user
    SET @sql = CONCAT('GRANT ALL PRIVILEGES ON `', v_db_name, '`.* TO ''app''@''%''');
    PREPARE stmt FROM @sql;
    EXECUTE stmt;
    DEALLOCATE PREPARE stmt;
    
    FLUSH PRIVILEGES;
    
    -- Return the created database name
    SELECT v_db_name AS database_name;
END$$

DELIMITER ;
