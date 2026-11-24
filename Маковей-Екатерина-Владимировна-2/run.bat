@echo off
setlocal

cd /d "%~dp0"

REM --- найти MSVC (vswhere + vcvarsall) ---
set "VSWHERE=%ProgramFiles(x86)%\Microsoft Visual Studio\Installer\vswhere.exe"
if not exist "%VSWHERE%" (
    echo [!] Visual Studio not found. Install VS or run from Developer Command Prompt.
    pause & exit /b 1
)

for /f "usebackq tokens=*" %%i in (`"%VSWHERE%" -latest -property installationPath`) do set "VSPATH=%%i"
call "%VSPATH%\VC\Auxiliary\Build\vcvars64.bat" >nul

REM --- собрать только если исходник новее exe ---
if not exist server.exe goto :build
if not exist client.exe goto :build
for %%f in (server.cpp) do if %%~tf GTR %~t0 goto :build
goto :run

:build
echo [*] Building...
cl /nologo /EHsc /std:c++17 /O2 server.cpp /Fe:server.exe /link ws2_32.lib >nul || goto :err
cl /nologo /EHsc /std:c++17 /O2 client.cpp /Fe:client.exe /link ws2_32.lib >nul || goto :err
echo [OK] Built.

:run
start "UDP SERVER" cmd /k server.exe
timeout /t 1 /nobreak >nul
start "UDP CLIENT" cmd /k client.exe
exit /b 0

:err
echo [!] Build failed.
pause
exit /b 1