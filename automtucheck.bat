@echo off
setlocal enabledelayedexpansion

REM Indirizzo IP di destinazione (puoi cambiarlo se necessario)
set TARGET=1.1.1.1

REM MTU iniziale
set MTU=1500

REM Decremento iniziale
set STEP=10

REM Logging
echo Determinazione della MTU massima senza frammentazione...
echo Destinazione: %TARGET%
echo Inizio test con MTU: %MTU%
echo.

REM Inizia con decrementi di STEP
:step_mode
echo Prova MTU: %MTU%
ping -f -l %MTU% %TARGET% >nul 2>&1
if %errorlevel% equ 0 (
    echo ^> Test riuscito: Nessuna frammentazione con MTU %MTU%
    REM Passa alla modalità di affinamento con incrementi di 1
    set /a STEP=1
    set /a MTU+=1
    goto refine_mode
) else (
    echo ^> Test fallito: Frammentazione con MTU %MTU%
    REM Riduce di STEP e continua
    set /a MTU-=%STEP%
    if %MTU% lss 0 (
        echo ^> Errore: Non è possibile determinare una MTU valida. Controlla la connessione.
        goto end
    )
    goto step_mode
)

REM Affina il valore della MTU con incrementi di 1
:refine_mode
echo Prova MTU: %MTU%
ping -f -l %MTU% %TARGET% >nul 2>&1
if %errorlevel% equ 0 (
    echo ^> Riuscito: Nessuna frammentazione con MTU %MTU%
    set /a MTU+=1
    goto refine_mode
) else (
    REM Torna al valore precedente
    set /a MTU-=1
    echo ^> Confermato: La dimensione massima del pacchetto senza frammentazione e': %MTU%
    goto end
)

:end
echo.
echo Test completato.
pause
