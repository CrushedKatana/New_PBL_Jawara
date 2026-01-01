@echo off
setlocal

REM Deploy backend PHP files to XAMPP htdocs\jawara\backend
REM Usage: double-click this file OR run from CMD

set SRC=%~dp0
set DEST=C:\xampp\htdocs\jawara\backend

echo === Deploy Jawara Backend to XAMPP ===
echo Source: %SRC%
echo Dest  : %DEST%
echo.

if not exist "%DEST%" (
  echo Creating folder: %DEST%
  mkdir "%DEST%"
)

echo Copying PHP and SQL files...
xcopy /Y /I "%SRC%*.php" "%DEST%\" >nul
xcopy /Y /I "%SRC%*.sql" "%DEST%\" >nul
xcopy /Y /I "%SRC%.gitignore" "%DEST%\" >nul

echo.
echo Done.
echo - Restart Apache in XAMPP Control Panel
echo - Import database.sql in phpMyAdmin if tables missing
pause
