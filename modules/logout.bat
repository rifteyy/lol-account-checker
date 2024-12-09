@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "ESC=%%b"A
)
for /f "delims=: tokens=3,4" %%A in ('type "!localappdata!\Riot Games\Riot Client\Config\lockfile"') do (
	set "auth_token=%%B"
	set "app_port=%%A"
)
set "riot_api=https://127.0.0.1:!app_port!"
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
set "riot_headers=-H "Authorization: Basic !lcu_session_token!" -H "Content-Type: application/json" -H "Accept: application/json""
set "riot=curl.exe --insecure -H "Content-Type: application/json" -H "Accept: application/json""
if "%~1"=="[X]" (
	echo=Processing logout...
)
!riot! -X DELETE !riot_headers! "https://127.0.0.1:!app_port!/rso-auth/v1/authorization"
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