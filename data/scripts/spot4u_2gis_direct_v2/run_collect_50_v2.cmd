@echo off
setlocal
cd /d "%~dp0"

set "PY="

if exist "%USERPROFILE%\anaconda3\python.exe" (
    set PY="%USERPROFILE%\anaconda3\python.exe"
    goto python_found
)
if exist "%USERPROFILE%\miniconda3\python.exe" (
    set PY="%USERPROFILE%\miniconda3\python.exe"
    goto python_found
)
where py >nul 2>nul
if not errorlevel 1 (
    set "PY=py -3"
    goto python_found
)
where python >nul 2>nul
if not errorlevel 1 (
    python --version >nul 2>nul
    if not errorlevel 1 (
        set "PY=python"
        goto python_found
    )
)

echo ERROR: Python not found.
pause
exit /b 1

:python_found
echo Using:
%PY% --version
echo.

%PY% -c "import requests" >nul 2>nul
if errorlevel 1 (
    %PY% -m pip install -r requirements.txt
    if errorlevel 1 goto fail
)

echo.
echo Starting Spot4u direct 2GIS collector v2...
echo.
%PY% collect_2gis_50_v2.py
if errorlevel 1 goto fail

echo.
echo DONE. Open data\places_2gis_50.csv
pause
exit /b 0

:fail
echo.
echo ERROR. Read the exact 2GIS error printed above.
pause
exit /b 1
