@echo off
setlocal enabledelayedexpansion

REM Configuration
set "backup_dir=D:\Backups"
set "source_dir=C:\Users\Documents"
set "sevenZip=C:\Program Files\7-Zip\7z.exe"

REM Create backup directory if it doesn't exist
if not exist "%backup_dir%" mkdir "%backup_dir%"

REM Get current date in YYYY-MM-DD format
for /f "tokens=2 delims==" %%d in ('wmic os get localdatetime /value ^| findstr "LocalDateTime"') do set datetime=%%d
set "datepart=!datetime:~0,4!-!datetime:~4,2!-!datetime:~6,2!"

REM Find the latest backup file
set "latest="
for /f "delims=" %%a in ('dir /b /a-d /od "%backup_dir%\Backup_*.7z" 2^>nul') do set "latest=%%a"

if defined latest (
    REM Get the timestamp of the latest backup
    for /f "usebackq" %%t in (`powershell -Command "(Get-Item '%backup_dir%\!latest!').LastWriteTime.ToString('yyyy-MM-ddTHH:mm:ss')"`) do set "timestamp=%%t"
    echo Creating incremental backup with files newer than !timestamp!
    "%sevenZip%" a -mx9 -t7z -ssw -r "-tn!timestamp!" "%backup_dir%\Backup_!datepart!.7z" "%source_dir%\*"
) else (
    echo No existing backup. Creating full backup...
    "%sevenZip%" a -mx9 -t7z -ssw -r "%backup_dir%\Backup_!datepart!.7z" "%source_dir%\*"
)

endlocal
