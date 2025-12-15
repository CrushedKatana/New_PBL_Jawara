-- ============================================
-- ADD RT_NUMBER AND RW_NUMBER TO USERS TABLE
-- ============================================
-- Run in phpMyAdmin: http://localhost/phpmyadmin
-- Database: marketplace_rtrw
-- ============================================

USE marketplace_rtrw;

-- Add rt_number and rw_number columns if not exists
ALTER TABLE users 
ADD COLUMN IF NOT EXISTS rt_number VARCHAR(10) DEFAULT '01' AFTER role,
ADD COLUMN IF NOT EXISTS rw_number VARCHAR(10) DEFAULT '02' AFTER rt_number;

-- Update existing users with default RT/RW if NULL
UPDATE users SET rt_number = '01' WHERE rt_number IS NULL OR rt_number = '';
UPDATE users SET rw_number = '02' WHERE rw_number IS NULL OR rw_number = '';

-- Show updated structure
DESCRIBE users;

SELECT '✅ RT_NUMBER and RW_NUMBER columns added!' as Status;
