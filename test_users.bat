@echo off
REM Quick Testing Script for Jawara Marketplace
REM Usage: test_users.bat

setlocal enabledelayedexpansion

set "BACKEND_URL=http://localhost/jawara/backend"

echo.
echo ====== Jawara Marketplace User Testing ======
echo.

REM Test Admin Login
echo Testing Admin Login...
echo.
curl -X POST "%BACKEND_URL%/auth.php" ^
  -H "Content-Type: application/json" ^
  -d "{\"action\": \"login\", \"email\": \"admin@jawara.com\", \"password\": \"Admin@123456\"}"

echo.
echo.

REM Test RT Login
echo Testing RT Login...
echo.
curl -X POST "%BACKEND_URL%/auth.php" ^
  -H "Content-Type: application/json" ^
  -d "{\"action\": \"login\", \"email\": \"rt1@jawara.com\", \"password\": \"RT@123456\"}"

echo.
echo.

REM Test Warga Login
echo Testing Warga Login...
echo.
curl -X POST "%BACKEND_URL%/auth.php" ^
  -H "Content-Type: application/json" ^
  -d "{\"action\": \"login\", \"email\": \"warga1@jawara.com\", \"password\": \"Warga@123456\"}"

echo.
echo Testing complete!
echo.
pause
