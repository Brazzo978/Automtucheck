@echo off
setlocal enabledelayedexpansion

REM Target IP address (you can change it if needed)
set TARGET=1.1.1.1

REM Initial MTU
set MTU=1500

REM Initial decrement
set STEP=10

REM Logging
echo Determining the maximum MTU without fragmentation...
echo Target: %TARGET%
echo Starting test with MTU: %MTU%
echo.

REM Start with STEP decrements
:step_mode
echo Testing MTU: %MTU%
ping -f -l %MTU% %TARGET% >nul 2>&1
if %errorlevel% equ 0 (
    echo ^> Test successful: No fragmentation with MTU %MTU%
    REM Switch to refinement mode with increments of 1
    set /a STEP=1
    set /a MTU+=1
    goto refine_mode
) else (
    echo ^> Test failed: Fragmentation with MTU %MTU%
    REM Decrease by STEP and continue
    set /a MTU-=%STEP%
    if %MTU% lss 0 (
        echo ^> Error: Unable to determine a valid MTU. Check the connection.
        goto end
    )
    goto step_mode
)

REM Refine the MTU value with increments of 1
:refine_mode
echo Testing MTU: %MTU%
ping -f -l %MTU% %TARGET% >nul 2>&1
if %errorlevel% equ 0 (
    echo ^> Successful: No fragmentation with MTU %MTU%
    set /a MTU+=1
    goto refine_mode
) else (
    REM Revert to the previous value
    set /a MTU-=1
    echo ^> Confirmed: The maximum MTU without fragmentation is: %MTU%
    goto end
)

:end
echo.
echo Test completed.
pause
