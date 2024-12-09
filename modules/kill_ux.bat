@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
title  
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "ESC=%%b"A
)
tasklist.exe /fi "ImageName eq LeagueClientUX.exe" /fo csv 2>NUL | find.exe /I "LeagueClientUX.exe">NUL
if !errorlevel! equ 1 (
	echo(
	echo([!ESC![1;31m^^!!ESC![0m] LeagueClientUX.exe process not running!ESC![0m
	exit /b 1
)
for /F "delims=" %%A in ('powershell.exe -Command ""^(Get-CimInstance Win32_Process -Filter \"name = 'LeagueClientUX.exe'\"^)[0].CommandLine""') do set "cmd.line.query=%%A"
for %%a in (!cmd.line.query!) do (
	for /f "tokens=1,2 delims==" %%c in ("%%~a") do (
		if "%%~c"=="--remoting-auth-token" set "auth_token=%%~d"
		if "%%~c"=="--app-port" set "app_port=%%~d"
	)
)
set "lcu_api=https://127.0.0.1:!app_port!"
echo(riot:!auth_token!>"tempTok.txt"
2>nul >nul certutil.exe -encode tempTok.txt encodedtempTok.txt
2>nul >nul certutil.exe -decode encodedtempTok.txt lcu_session_token.txt
for /f "delims=" %%A in (encodedtempTok.txt) do (
	set "temp_lcu=%%A"
	if not "!temp_lcu:~0,1!"=="-" (
		set "lcu_session_token=%%A"
		set "temp_lcu="
	)
)
2>nul del /f /q "encodedtempTok.txt"
2>nul del /f /q "lcu_session_token.txt"
2>nul del /f /q "tempTok.txt"
call :strLen lcu_session_token
if "!lcu_session_token:~-4,%len%!"=="DQo=" (
	set "lcu_session_token=!lcu_session_token:~0,-4!"
)
set "lcu_headers=-H "Authorization: Basic !lcu_session_token!"-H "Content-Type: application/json" -H "Accept: application/json""
set "lcu=curl.exe --insecure -H "Authorization: Basic !lcu_session_token!" -H "Content-Type: application/json" -H "Accept: application/json""
!lcu! -X POST "!lcu_api!/riotclient/kill-ux"
exit /b 0

:strLen <string>
set "_tmp=!%1!"
set len=0
for %%A in (4096,2048,1024,512,256,128,64,32,16,8,4,2,1) do (
    if not "!_tmp:~%%A,1!"=="" (
        set /a "len+=%%A"
        set "_tmp=!_tmp:~%%A!"
    )
)
set /a len+=1
if !len! equ 4100 set len=0
exit /b