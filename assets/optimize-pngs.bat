@echo off
echo 🔧 Optimizing PNG files in folder: %cd%
echo.

:: Check if pngquant is available
where pngquant >nul 2>&1
if errorlevel 1 (
    echo ❌ pngquant not found in PATH.
    echo 👉 Please make sure pngquant.exe is in this folder or added to PATH.
    pause
    exit /b
)

:: Loop through all PNG files
for %%f in (*.png) do (
    echo ▶ Compressing: %%f
    pngquant --quality=80-100 --ext .png --force "%%f"
)

echo.
echo ✅ All PNGs processed.
pause
