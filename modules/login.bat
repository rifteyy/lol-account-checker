@Echo off
setlocal enabledelayedexpansion
chcp 437>nul
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "ESC=%%b"
)
if "%~3"=="" exit /b
2>nul >nul (
taskkill /F /IM "league*"
taskkill /F /IM "riot*"
)
for /f "delims=" %%A in (settings\settings.txt) do set "%%A"
if not "%~4"=="showui" (
	start "" "!riot_client_services!" --headless
) else start "" "!riot_client_services!"
if "%~4"=="[X]" echo=Started !riot_client_services! [!errorlevel!]
timeout /T 5 /NOBREAK >nul
if "%~4"=="[X]" echo=Lockfile loop
:lockfile_loop
if exist "!localappdata!\Riot Games\Riot Client\Config\lockfile" (
	if "%~4"=="[X]" echo=Lockfile found
	for /f "delims=: tokens=3,4" %%A in ('type "!localappdata!\Riot Games\Riot Client\Config\lockfile"') do (
		set "auth_token=%%B"
		set "app_port=%%A"
	)
) else (
	if !fail! equ 7 (
		if not "%~4"=="showui" (
			start "" "!riot_client_services!" --headless
		) else start "" "!riot_client_services!"
	)
	if !fail! equ 10 (
		echo=Riot Client could not be started.
		if not exist "!localappdata!\Riot Games\Riot Client\Config\lockfile" (
			echo=Lockfile does not exist.
			echo="!localappdata!\Riot Games\Riot Client\Config\lockfile"
		)
		>nul pause
		exit /b 0	
	)
	set /a fail+=1
	timeout /T 1 /NOBREAK >nul
	goto :lockfile_loop
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
pushd "%temp%"
if "%~4"=="[X]" echo=Making request
set "riot_headers=-H "Authorization: Basic !lcu_session_token!" -H "Content-Type: application/json" -H "Accept: application/json""
if not "%~5"=="" (
	set "riot=curl.exe --insecure -H "Content-Type: application/json" -H "Accept: application/json" -x http://%~5"
) else (
	set "riot=curl.exe --insecure -H "Content-Type: application/json" -H "Accept: application/json""
)
if "%~4"=="[X]" echo=!riot!
set "data={\"username\":\"%~1\",\"password\":\"%~2\",\"persistLogin\":false}"
!riot! --no-progress-meter --silent -X PUT !riot_headers! "https://127.0.0.1:!app_port!/rso-auth/v1/session/credentials" -d "!data!" -o "resp.json"
for /f "delims=, tokens=1,2" %%A in ('powershell.exe -Command "$json = Get-Content -Path 'resp.json' | ConvertFrom-Json; Write-Output ($json.error + ',' + $json.type)"') do (
	popd
	2>nul del /f /q resp.json
	if "%~4"=="[X]" echo=First RESP: %%A
	if /i "%%A"=="auth_failure" (
		exit /b 1
	) else if /i "%%A"=="rate_limited" (
		exit /b 2
	) else if /i "%%A"=="needs_multifactor_verification" (
		exit /b 3
	) else if /i "%%A"=="authenticated" (
		timeout /T 10 /NOBREAK >nul
		!Riot! --no-progress-meter --silent -X PUT !riot_headers! "https://127.0.0.1:!app_port!/eula/v1/agreement/acceptance"
		exit /b 0
		)
	)
)
for /f "delims=" %%A in (resp.json) do (
	if "%%A"=="{"errorCode":"RPC_ERROR","httpStatus":513,"implementationDetails":{},"message":"Malformed request"}" (
		del /f /q log.json 2>nul >nul
		!riot! --no-progress-meter -X GET !riot_headers! "https://127.0.0.1:!app_port!/riot-login/v1/status" -o "log.json"
		for /f "delims=" %%B in ('powershell.exe -command "$json = Get-Content -Path 'log.json' | ConvertFrom-Json; $json.phase"') do (
			!riot! --no-progress-meter --silent -X PUT !riot_headers! "https://127.0.0.1:!app_port!/rso-auth/v1/session/credentials" -d "!data!"
			del /f /q log.json 2>nul >nul
			if "%~4"=="[X]" echo=Malformed request, status=%%B
			if "%%B"=="not_logged_in" exit /b 2
			if "%%B"=="logged_in" exit /b 0
		)
	)
)
exit /b 0


:strlen
set "tmp=!%~1!"
if defined tmp (
    set "len=1"
    for %%p in (4096 2048 1024 512 256 128 64 32 16 8 4 2 1) do (
        if "!tmp:~%%p,1!" neq "" (
            set /a "len+=%%p"
            set "tmp=!tmp:~%%p!"
        )
    )
) else (
    set len=0
)
exit /b 0



