@echo off
setlocal enabledelayedexpansion
for /F %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
cd /d "%~dp0"
title Open Checker - Launcher
for %%A in (
"Check_Prime_Capsules_Count.ps1"
"Decode_JWT.ps1"
"Dialog_Save_As_TXT.ps1"
"export.bat"
"Extract_Skins_And_Obtain_Date.ps1"
"kill_ux.bat"
"login.bat"
"logout.bat"
"main.bat"
"main.ico"
"Obtain_Champion_List_And_Obtain_Date.ps1"
"Parse_FlexQ.ps1"
"Parse_Friendlist.ps1"
"Parse_ID.ps1"
"Parse_Matches.ps1"
"Parse_Rank.ps1"
"Parse_SoloQ.ps1"
"rare_skins_check.bat"
"Replace_SkinID_Skin_Name.ps1"
"Select_TXT_In_Explorer.ps1"
"Sort_By_Date_Skins.ps1"
"Wallet_Parse.ps1"
) do if not exist "modules\%%~A" (
	echo=!ESC![38;2;255;0;0mFATAL ERROR: modules\%%~A was not found, please redownload whole Open Checker.
	>nul pause
	exit
)
if not exist "settings\rare_skins.txt" (
	(echo=Silver Kayle
	echo=Young Ryze
	echo=Black Alistar
	echo=Rusty Blitzcrank
	echo=UFO Corki
	echo=King Rammus
	echo=PAX Twisted Fate
	echo=PAX Jax
	echo=PAX Sivir
	echo=Riot Squad Singed
	echo=Judgement Kayle
	echo=Urfwick
	echo=Urf The Manatee
	echo=Triumphant Ryze
	echo=Worlds 2012 Riven
	echo=Victorious Elise
	echo=Victorious Janna
	echo=Victorious Jarvan IV
	)>>"settings\rare_skins.txt"
)
if not exist "settings\settings.txt" (
	if exist "!systemdrive!\Riot Games\League of Legends\LeagueClient.exe" (
		echo.league_client=!systemdrive!\Riot Games\League of Legends\LeagueClient.exe>>"settings\settings.txt"
	) else (
		set /p "league_client=LeagueClient.exe path not found, please specify: "
		echo.league_client=!league_client!
	)
	if exist "!systemdrive!\Riot Games\Riot Client\RiotClientServices.exe" (
		echo.riot_client_services=!systemdrive!\Riot Games\Riot Client\RiotClientServices.exe>>"settings\settings.txt"
	) else (
		set /p "riot_client_services=RiotClientServices.exe path not found, please specify: "
		echo.riot_client_services=!riot_client_services!
	)
	(
	echo=r=125
	echo=g=147
	echo=b=205
	echo=censormode=[ ]
	echo=debug=[ ]
	) >>"settings\settings.txt"
)
if exist "%~1" (
	if not "%~x1"==".ockr" (
		echo=!ESC![38;2;255;0;0mFATAL ERROR: File extension is not .ockr
		>nul pause
		exit
	)
	start "%~dp0modules\main.ico" cmd /c "%~dp0modules\main.bat" %~1
	exit /b 0	
)
start "%~dp0modules\main.ico" cmd /c "%~dp0modules\main.bat" 
exit /b 0