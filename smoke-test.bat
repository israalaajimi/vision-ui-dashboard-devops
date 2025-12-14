@echo off
setlocal enabledelayedexpansion

:: Set timeout and retry
set MAX_RETRIES=10
set RETRY_DELAY=5
set PORT=8081

echo Waiting for application to start on port %PORT%...

for /l %%i in (1,1,%MAX_RETRIES%) do (
    curl -s -o nul -w "%%{http_code}" http://localhost:%PORT% > response.txt
    set /p STATUS=<response.txt
    
    if "!STATUS!"=="200" (
        echo SMOKE TEST PASSED - Application is responding (Attempt %%i)
        del response.txt 2>nul
        exit /b 0
    ) else (
        echo Attempt %%i: Got status !STATUS!, retrying in %RETRY_DELAY% seconds...
        timeout /t %RETRY_DELAY% /nobreak >nul
    )
)

echo SMOKE TEST FAILED - Application did not respond after %MAX_RETRIES% attempts
del response.txt 2>nul
exit /b 1