-- Grant permissions for multi-tenant pattern
-- Allows app user to access all databases with tenant_ prefix
GRANT ALL ON `tenant_%`.* TO 'app'@'%';

-- Grant permissions for test databases
GRANT ALL ON `test_%`.* TO 'app'@'%';

-- For single-tenant/normal mode, create a main application database
-- CREATE DATABASE IF NOT EXISTS main_app CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
-- GRANT ALL ON main_app.* TO 'app'@'%';

-- Example tenant databases (remove in production)
CREATE DATABASE IF NOT EXISTS tenant1;
GRANT ALL ON tenant1.* TO 'app'@'%';
