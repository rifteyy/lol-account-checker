@echo off
setlocal enabledelayedexpansion
if "%~1"=="pressr" (
	chcp 65001>nul
	mode 140,33
	goto :pressr
)
for /f "delims=" %%E in (
    'forfiles /p "%~dp0." /m "%~nx0" /c "cmd /c echo(0x1B"'
) do (
    set "ESC=%%E"
)
cd /d "%~dp0.."
if exist "%*" (
	set "list=%*"
) else (
	set list_sel_check=true
)
:restart_full
chcp 65001>nul
set "settings=settings\settings.txt"
set "settings_folder=settings"
call :set_settings
set "ver=v1.0"
title  
mode 140,33
set acc=0
set total_lines=0
if not !list_sel_check!==true (
for /f "delims=" %%A in ("!list!") do set "listname=%%~nA"
for /f "delims=" %%A in ('findstr.exe "summoner[" "!list!"') do (
	set /a acc+=1
)
set "bracket=─"
set "String=Importing total of !acc! accounts from !listname!, please wait..."
call :strLen string len
for /l %%a in (0,1,!len!) do set "bracket=!bracket!─"
set /a pos=140/2 - 2 - !len!/2
set /a pos1=pos+20
rem echo=!ESC![13;!pos1!H!sel_norm_clr!Open Checker!ESC![0m
echo=!ESC![14;!pos!H!ESC![?25l┌!bracket!┐
echo=!ESC![15;!pos!H│ Importing total of !ESC![4m!sel_norm_clr!!acc!!ESC![0m accounts from !ESC![4m!sel_norm_clr!!listname!!ESC![0m, please wait... │
echo=!ESC![16;!pos!H└!bracket!┘
set linesloaded=0
set show_loading=false
set "starttime=%time%"
if "!show_loading!"=="true" (
	set loaded_percent=0
	set milestone_info=
	set "onepercent_info=0"
	set total_info=0
	set loaded_info=0
	for /f "delims=" %%A in ('type "!list!"') do (
		set /a total_info=total_info+=1
	)
	set /a "onepercent_info=total_info/100"
	set /a "milestone_info=!onepercent_info!"
)
for /f "delims=" %%A In ('type "!list!"') do (
	set "%%~A" 2>nul >nul
	if "!show_loading!"=="true" (
		set /a "loaded_info+=1"
		echo=!ESC![13;!pos1!H!sel_norm_clr!Loaded !loaded_info!/!total_info!!ESC![0m
	)
)

)
cd /d "%~dp0.."
set "endtime=%time%"
chcp 65001>nul
for /f %%A in ('"prompt $H&for %%B in (1) do rem"') do set "BS=%%A"
for /f %%a in ('copy /Z "%~dpf0" nul') do set "\r=%%a"
set "num_clr=!ESC![48;2;37;40;48m"

set "spacescount=35"
set friendscount=0
set "lowerspacescount=25"
set /a scnd_space=spacescount + 20
set /a thrd_space=spacescount + 40
set /a fourth_space=spacescount + 70
set /a fifth_space=spacescount + 90
set max_y=20
if not defined fullspace for /l %%A in (1 1 140) do set "fullspace=!fullspace! "
set /a searchsel=1
set listsel=1
set list_sel=1
set \n=^


rem two empty line required
:refresh_database
call :set_settings
for /F %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"
if not defined clearspaces for /l %%A in (1 1 80) do set "clearspaces=!clearspaces! "
if !list_sel_check!==true (
	set list_sel_Check=false
	goto :list_sel
)
goto :refresh

:list_sel
echo=!ESC![?25l!ESC![1;1H
echo=        ▄▄▄·▄▄▄ . ▐ ▄ 
echo= ▪     ▐█ ▄█▀▄.▀·•█▌▐█
echo=  ▄█▀▄  ██▀·▐▀▀▪▄▐█▐▐▌
echo= ▐█▌.▐▌▐█▪·•▐█▄▄▌██▐█▌
echo=  ▀█▄▀▪.▀    ▀▀▀ ▀▀ █▪
echo=!ESC![3;25H╭───────────────────────────────────────────────────────────────────────╮
echo=!ESC![4;25H│ Open Checker !sel_norm_Clr!!ver!!esc![0m, AIO League of Legends account manager and checker. │
echo=!ESC![5;25H│ Press X to select a choice, W and S to go up and down.                │
echo=!ESC![6;25H╰───────────────────────────────────────────────────────────────────────╯
if not defined latest_patch (
	echo=!ESC![8;2HChecking for updates...
	call :get_patch
	echo=!ESC![8;2H                 
)
for /f "delims=" %%A in ('type "settings\patch.txt"') do (
	if "%%~A"=="!latest_patch!" (
		echo=!ESC![8;1H Files are up-to-date with patch !sel_norm_clr!!latest_patch!!ESC![0m
	) else (
		echo=!ESC![8;1H !ESC![1;31mWARNING: Files are not up-to-date with the patch !latest_patch! ^(You have patch %%~A^)!ESC![0m
	)
)
for %%A in (tftbooms tftmap summoner_icons tftcompanion) do if not exist "modules\%%A.json" (
	set "warn_status=true"
)
if "!warn_status!"=="true" (
	echo= !ESC![1;31mWARNING: There are missing files. Please select option to update/repair files.!ESC![0m
) else (
	echo= All files are downloaded and everything should be working perfectly.
)
set "warn_status="
echo=!ESC![11;1H
if !list_sel! equ 1 (
	echo= !sel_norm_clr!Create new list!ESC![0m
) else (
	echo= Create new list!ESC![0m
)
if !list_sel! equ 2 (
	echo= !sel_norm_clr!Drag into this window to import a list!ESC![0m
) else (
	echo= Drag into this window to import a list
)
if !list_sel! equ 3 (
	echo= !sel_norm_clr!Select list in explorer window!ESC![0m
) else ( 
	echo= Select list in explorer window!ESC![0m
)
if !list_sel! equ 4 (
	echo= !sel_norm_clr!Associate .OCKR files with start.bat ^(this will allow to open by doubleclicking .OCKR list^)!ESC![0m
) else ( 
	echo= Associate .OCKR files with start.bat ^(this will allow to open by doubleclicking .OCKR list^)
)
if !list_sel! equ 5 (
	echo= !sel_norm_clr!Update/repair files containing skin names, icon names and TFT items ^(Recommended after new patch^)!ESC![0m
) else ( 
	echo= Update/repair files containing skin names, icon names and TFT items ^(Recommended after new patch^)
)

if defined listname if !list_sel! equ 6 (
	echo= !sel_norm_clr!Exit back to !listname! list!ESC![0m
) else ( 
	echo= Exit back to !listname! list!ESC![0m
)
call :xcopy
if /i "!key!"=="x" (
	if !list_sel! equ 1 (
		chcp 437>nul
		for /f "delims=" %%A in ('PowerShell -Command "[void][System.Reflection.Assembly]::LoadWithPartialName('System.windows.forms'); $sfd = New-Object System.Windows.Forms.SaveFileDialog; $sfd.Filter = 'OCKR files (*.ockr)|*.ockr'; if ($sfd.ShowDialog() -eq 'OK') { New-Item -Path $sfd.FileName -ItemType File -Force; Write-Host $sfd.FileName }"') do (
			set "list=%%~A"
			set "listname=%%~nA"
		)
		chcp 65001>nul
		echo=!ESC![2J!ESC![1;1H
		goto :restart_full
	)
	if !list_sel! equ 3 (
		chcp 437>nul
		for /f "delims=" %%A in ('powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $dialog = New-Object System.Windows.Forms.OpenFileDialog; $dialog.Filter = 'OCKR files (*.ockr)|*.ockr'; $dialog.ShowDialog() | Out-Null; Write-Output $dialog.FileName"') do (
			set "list=%%A"
			set "listname=%%~nA"
		)
		chcp 65001>nul
		echo=!ESC![2J!ESC![1;1H
		goto :restart_full
	)
	if !list_sel! equ 4 (
		net.exe session 2>nul >nul || (
			echo= !ESC![1;31mError:!ESC![0m You have to be running this file as administrator in order to associate .OCKR extension to Open Checker files. 
			echo= Re-run as administrator and launch this file and select this option again, then you can relaunch this file normally as always.
			>nul pause
			echo=!ESC![2J!ESC![1;1H
			goto :list_sel
		)
		>nul assoc .ockr=Open Checker list file && (
			echo= Successfully set description of .OCKR files.
		) || (
			echo= Failed to set description of .OCKR files.
		)
		set "tmp_dir=%~dp0"
		set "tmp_dir=!tmp_dir:~0,-1!\.."
		>nul ftype Open Checker list file="!tmp_dir!\start.bat" "%%0" && (
			echo= Successfully associated start.bat path to .OCKR files.
		) || (
			echo= Failed to associate start.bat to .OCKR files.
		)
		echo= Done associating.
		>nul pause
		echo=!ESC![2J!ESC![1;1H
		goto :list_sel
	)

	if !list_sel! equ 5 (
		echo= Updating files, please wait...
		for %%A in (summoner_icons tftcompanion tftbooms tftmap) do del /f /q "modules\%%A.json" 2>nul >nul
		curl.exe  "https://raw.communitydragon.org/latest/plugins/rcp-be-lol-game-data/global/default/v1/summoner-icons.json" -o "modules\summoner_icons.json"
		curl.exe  "https://raw.communitydragon.org/latest/plugins/rcp-be-lol-game-data/global/default/v1/companions.json" -o "modules\tftcompanion.json"
		curl.exe  "https://raw.communitydragon.org/latest/plugins/rcp-be-lol-game-data/global/default/v1/tftdamageskins.json" -o "modules\tftbooms.json"
		curl.exe  "https://raw.communitydragon.org/latest/plugins/rcp-be-lol-game-data/global/default/v1/tftmapskins.json" -o "modules\tftmap.json"
		call :get_patch
		echo=!latest_patch!>"settings\patch.txt"
		echo= All files have been successfully updated to patch !latest_patch!
		>nul pause
		echo=!ESC![2J!ESC![1;1H
	)
	if !list_sel! equ 2 (
		set /p "list=Paste the full list path here: "
		set "list=!list:"=!"
		if not exist "!list!" (
			echo=ERROR: Path does not exist.
			>nul pause
			echo=!ESC![2J!ESC![1;1H
			goto :list_sel
		)
		for /f "delims=" %%A in ("!list!") do set "listname=%%~nA"
		goto :restart_full
	)
	if !list_sel! equ 6 (
		echo=!ESC![2J!ESC![1;1H
		if defined list goto :disp
	)
)
if /i "!key!"=="w" if not !list_sel! leq 1 set /a list_sel-=1
if /i "!key!"=="s" (
	if defined listname (
		if not !list_sel! geq 6 set /a list_sel+=1
	) else if not !list_sel! geq 5 set /a list_sel+=1
)
goto :list_sel

:refresh
set /a gi=0
for /f "delims=: tokens=1,2" %%A in ('type "modules\gift_icons.txt"') do (
	set /a gi+=1
	set "gift_icon_name[!gi!]=%%~A"
	set "gift_icon_desc[!gi!]=%%~B"
)
if not defined esc for /F %%a in ('echo prompt $E^| cmd') do set "ESC=%%a"

for /f "delims=" %%A In ('type "!list!"') do (
	set "%%~A" 2>nul >nul
)
set acc=0
for /f "delims=" %%A in ('findstr.exe "summoner[" "!list!"') do (
	set /a acc+=1
)
if !acc! equ 0 (
	echo=!ESC![2J!ESC![1;1H
	echo=!ESC![?25l!ESC![14;3HIt seems like you have no accounts imported. If you would like to import an account,
	echo=!ESC![15;3Hselect !sel_norm_clr!Import!ESC![0m and then you can import with credentials, from a TXT file or the account you are currently logged to.
	>nul pause
)
set acc_to_show=0
set sel=1
set upsel=1
rem !ESC![38;5;241mPress V to change list!ESC![0m
set "starting_bar=echo=!ESC![1;7H!ESC![38;5;241mPress V to change list!ESC![0m!ESC![?25l!ESC![1;36HList!ESC![1;42HCopy!ESC![1;48HImport!ESC![1;56HExport!ESC![1;64HSettings!ESC![1;74HSearch!esc![1;82HRecovery info!ESC![2;1H"
set opt[1]=List
set opt[2]=Copy
set opt[3]=Import
set opt[4]=Export
set opt[5]=Settings
set opt[6]=Search
set opt[7]=Recovery info
set "starting_bar=!starting_bar:%sel_norm_clr%%option%%ESC%[0m=%option%!"
set option=!opt[%upsel%]!
set "starting_bar=!starting_bar:%option%=%sel_norm_clr%%option%%ESC%[0m!"
echo=!ESC![2J!ESC![1;1H

:disp
>nul chcp 65001
if !Search!==true set skiponce=yes
if !search!==true (
	title !title_search!; Press T to stop searching
) else title !listname!
if not defined rare[!sel!] set rare[!sel!]=?
%starting_bar%!ESC![1;1H!ESC![112GRare skins: !rare[%sel%]!  
echo=!num_clr!!fullspace!
echo=!num_clr!#     Region   Username           Summoner name          Email    Level    RP       BE      Champs   Skins     SoloQ         FlexQ          
echo=!fullspace!!ESC![0m
if not "!search!"=="true" for /l %%A in (1,1,!acc!) do (
	if %%A LSS 100 set "n=%%A    "
	if %%A LSS 10 set "n=%%A     "
	if %%A equ !sel! (
		echo.!sel_clr!!n!!esc![0m!sel_norm_clr!!esc![7G!region[%%A]!!esc![16G!censor_clr!!login[%%A]!!esc![35G!summoner[%%A]!!sel_norm_clr!!esc![58G!emailverified[%%A]!!esc![67G!level[%%A]!!esc![76G!rp[%%A]!!esc![84G!be[%%A]!!esc![93G!champsamount[%%A]!!esc![102G!skinsamount[%%A]!!esc![111G!rank[solo][%%A]!!esc![126G!rank[flex][%%A]!!ESC![0m
	) else (
		echo.!num_clr!!n!!esc![0m!esc![7G!region[%%A]!!esc![16G!censor_clr!!login[%%A]!!esc![35G!summoner[%%A]!!esc![0m!esc![58G!emailverified[%%A]!!esc![67G!level[%%A]!!esc![76G!rp[%%A]!!esc![84G!be[%%A]!!esc![93G!champsamount[%%A]!!esc![102G!skinsamount[%%A]!!esc![111G!rank[solo][%%A]!!esc![126G!rank[flex][%%A]! 
		
	)
)
if "!search!"=="true" for /l %%A in (1 1 !acc!) do for /f %%# in ("!number[%%A]!") do (
	if %%A LSS 100 set "n=%%A    "
	if %%A LSS 10 set "n=%%A     "
	if %%A equ !sel! (
		if not "!acc_to_disp!"=="!acc_to_disp:,%%~#,=!" echo.!sel_clr!!n!!esc![0m!sel_norm_clr!!esc![7G!region[%%A]!!esc![16G!censor_clr!!login[%%A]!!esc![35G!summoner[%%A]!!sel_norm_clr!!esc![58G!emailverified[%%A]!!esc![67G!level[%%A]!!esc![76G!rp[%%A]!!esc![84G!be[%%A]!!esc![93G!champsamount[%%A]!!esc![102G!skinsamount[%%A]!!esc![111G!rank[solo][%%A]!!esc![126G!rank[flex][%%A]!!ESC![0m
		) else (
			echo.!num_clr!!n!!esc![0m!esc![7G!region[%%A]!!esc![16G!censor_clr!!login[%%A]!!esc![35G!summoner[%%A]!!esc![0m!esc![58G!emailverified[%%A]!!esc![67G!level[%%A]!!esc![76G!rp[%%A]!!esc![84G!be[%%A]!!esc![93G!champsamount[%%A]!!esc![102G!skinsamount[%%A]!!esc![111G!rank[solo][%%A]!!esc![126G!rank[flex][%%A]!	
				)
			)
		)
	)
) 


:choice_repeat
if not defined rare[!sel!] set rare[!sel!]=?
%starting_bar%!ESC![1;1H!ESC![112GRare skins: !rare[%sel%]!
echo=!num_clr!!fullspace!
echo=!num_clr!#     Region   Username           Summoner name          Email    Level    RP       BE      Champs   Skins     SoloQ         FlexQ          
echo=!fullspace!!ESC![0m
call :xcopy
if /i "!key!"=="s" (
	if not !search!==true (
		if not !sel! geq !acc! (
			set /a sel+=1
			set change=yes
		)
	) else (
		if not !nj_sel! geq !nloop! (
			set /a nj_sel+=1
			set change=yes
		)
	)
)
if /i "!key!"=="w" (
	if not !search!==true (
		if not !sel! leq 1 (
			set /a sel-=1
			set change=yes
		)
	) else (
		if not !nj_sel! leq 1 (
			set /a nj_sel-=1
			set change=yes
		)
	)
)
if not defined prev_sel set prev_sel=1
if !search!==true set sel=!nj_sel!
set /a ypos_current=4 + !sel!
set /a ypos_old=4 + !prev_sel! 2>nul >nul
if !ypos_current! lss 10 (set "n_current=!sel!      ") else (set "n_current=!sel!     ")
if !ypos_old! lss 10 (set "n_old=!prev_sel!      ") else (set "n_old=!prev_sel!     ")
if !change!==yes (
echo.!ESC![!ypos_current!;1H!sel_clr!!n_current!!esc![0m!sel_norm_clr!!esc![7G!region[%sel%]!  !esc![16G!censor_clr!!login[%sel%]!         !esc![35G!summoner[%sel%]!        !sel_norm_clr!!esc![58G!emailverified[%sel%]!   !esc![67G!level[%sel%]!    !esc![76G!rp[%sel%]!     !esc![84G!be[%sel%]!     !esc![93G!champsamount[%sel%]!      !esc![102G!skinsamount[%sel%]!      !esc![111G!rank[solo][%sel%]!      !esc![126G!rank[flex][%sel%]!      !ESC![0m
echo.!ESC![!ypos_old!;1H!num_clr!!n_old!!esc![0m!esc![7G!region[%prev_sel%]!   !esc![16G!censor_clr!!login[%prev_sel%]!      !esc![35G!summoner[%prev_sel%]!       !esc![0m!esc![58G!emailverified[%prev_sel%]!     !esc![67G!level[%prev_sel%]!    !esc![76G!rp[%prev_sel%]!     !esc![84G!be[%prev_sel%]!    !esc![93G!champsamount[%prev_sel%]!    !esc![102G!skinsamount[%prev_sel%]!     !esc![111G!rank[solo][%prev_sel%]!     !esc![126G!rank[flex][%prev_sel%]! 
set prev_sel=!sel!
)
set change=no
rem if !search!==true set sel=!number[%nj_sel%]!
if /i "!key!"=="v" (
	echo=!ESC![2J!ESC![1;1H
	goto :list_sel
)
if /i "!key!"=="e" (
	if not !upsel! geq 7 set /a upsel+=1
		
)
if /i "!key!"=="t" (
	if !search!==true (
		for /l %%A in (1 1 !nloop!) do (
			set "number[%%A]="
			set "nj[%%A]="
		)
		set "nj_sel="
		set "nums="
		set "number_jump="
		set "tmp_n="
		set search=false
		echo=!ESC![2J!ESC![1;1H
	)
)
if /i "!key!"=="t" (
	if !search!==true (
		for /l %%A in (1 1 !nloop!) do (
			set "number[%%A]="
			set "nj[%%A]="
		)
		set "nj_sel="
		set "nums="
		set "number_jump="
		set "tmp_n="
		set search=false
		echo=!ESC![2J!ESC![1;1H
	)
)
if /i "!key!"=="q" (
	if not !upsel! leq 1 set /a upsel-=1
)
if /i "!key!"=="a" (
	echo=!ESC![2J!ESC![1;1H
	echo=Logging in to [!sel_norm_clr!!region[%sel%]!!esc![0m] !login[%sel%]!...
	chcp 437>nul
	for %%A in ("" "no" "No") do if "!password[%sel%]!"=="%%~A" (
		echo=[!ESC![38;2;255;0;0mERROR!ESC![0m] Password is not saved.
		>nul pause
		echo=!ESC![2J!ESC![1;1H!ESC![?25l
		goto :disp
	)
	call "modules\logout.bat" "!debug!"
	timeout.exe /T 3 /NOBREAK >nul
	call "modules\login.bat" "!login[%sel%]!" "!password[%sel%]!" openchecker "!debug!"
	if !errorlevel! equ 1 (
		echo=[!ESC![38;2;255;0;0mERROR!ESC![0m] Invalid password.
	) else if !errorlevel! equ 2 (
		echo=[!ESC![38;2;255;0;0mERROR!ESC![0m] Rate limited. Use VPN or wait a bit.
	) else if !errorlevel! equ 3 (
		echo=[!ESC![38;2;255;0;0mERROR!ESC![0m] Account has MFA enabled, can not be logged into.
	) else if !errorlevel! equ 4 (
		echo=[!ESC![38;2;255;165;0m?!ESC![0m] Malformed request, unknown if logged in or not.
		echo=Starting league...
		start "" "!riot_client_services!" --launch-product=league_of_legends --launch-patchline=live
		if !errorlevel! equ 0 echo=[!ESC![38;2;0;255;0mSUCCESS!ESC![0m] League has been launched.
	) else if !errorlevel! equ 0 (
		echo=[!ESC![38;2;0;255;0mAUTHENTICATED!ESC![0m] Logged in^^!
		echo=Starting league...
		start "" "!riot_client_services!" --launch-product=league_of_legends --launch-patchline=live
	)
	
	:manual_pw
	if "!password[%sel%]!"=="No password saved." (
		echo=Would you like to manually add a password? [Y/N]
		echo=It will stay encrypted and not accessible if your personal files were stolen.
		choice.exe /c yn >nul
		if !errorlevel! equ 1 (
			set /p "password=!ESC![?25hEnter password for the account: "
			call "modules\logout.bat" "!debug!"
			timeout.exe /T 3 /NOBREAK >nul
			call "modules\login.bat" "!login[%sel%]!" "!password!" openchecker "!debug!"
			if !errorlevel! equ 1 (
				echo=[!ESC![38;2;255;0;0mERROR!ESC![0m] Invalid password.
			) else if !errorlevel! equ 2 (
				echo=[!ESC![38;2;255;0;0mERROR!ESC![0m] Rate limited. Use VPN or wait a bit.
			) else if !errorlevel! equ 3 (
				echo=[!ESC![38;2;255;0;0mERROR!ESC![0m] Account has MFA enabled, can not be logged into.
			) else if !errorlevel! equ 4 (
				echo=[!ESC![38;2;255;165;0m?!ESC![0m] Success, but malformed request. [RESP_CODE=513]
				echo=Exporting password...
				call :export_pw "!password!"
				echo=Done^^!
				echo=Try again to autologin now.
			) else if !errorlevel! equ 0 (
				echo=[!ESC![38;2;0;255;0mAUTHENTICATED!ESC![0m] Logged in^^!
				echo=Exporting password...
				call :export_pw "!password!"
				echo=Done^^!
				echo=Try again to autologin now.
			)
		)
	)
	>nul pause
	echo=!ESC![2J!ESC![1;1H!ESC![?25l
	goto :disp
)
if /i "!key!"=="x" (
		if "!censormode!"=="[X]" (
			title !region[%sel%]! - Censored
		) else (
			title !region[%sel%]! - !summoner[%sel%]!
		)
		if !upsel!==1 (
			title !listname!
			set c=!sel_norm_clr!
			set re=!ESC![0m
			for %%A in (vn tr ru sg na euw eune oce lan las br) do set "region[%%A]=0"
			for %%A in (0 1to2 3to4 5to6 over6) do set "rare_skins[%%A]=0"
			for %%A in (0 1to20 21to50 51to100 101to150 151to200 over200) do set "skins[%%A]=0"
			for %%A in (verifiedmail unverifiedmail) do set "%%A=0"
			for %%A in (0 1to350 350to1000 1000to2000 2000to3000 3000to5000 over5000) do set "rpo[%%A]=0"
			for %%A in (unranked iron bronze silver gold platinum emerald diamond master grandmaster challenger) do (
				set "solo[%%A]=0"
				set "flex[%%A]=0"
			)
			for /l %%A in (1 1 !acc!) do (
				set /a "region[!region[%%A]!]+=1"
				if not "!rare[%%A]!"=="0" (
					if !rare[%%A]! equ 1 (
						set /a "rare_skins[1to2]+=1"
					) else if !rare[%%A]! equ 2 (
						set /a "rare_skins[1to2]+=1"
					) else if !rare[%%A]! equ 3 (
						set /a "rare_skins[3to4]+=1"
					) else if !rare[%%A]! equ 4 (
						set /a "rare_skins[3to4]+=1"
					) else if !rare[%%A]! equ 5 (
						set /a "rare_skins[5to6]+=1"
					) else if !rare[%%A]! equ 6 (
						set /a rare_skins[5to6]+=1"
					) else if !rare[%%A]! gtr 6 (
						set /a rare_skins[over6]+=1"
					)
				) else set /a "rare_skins[0]+=1"
				if /i "!RANKED_SOLO_5X5[rank][%%A]!"=="" (
					set /a "solo[unranked]+=1"
				) else (
					set /a "solo[!RANKED_SOLO_5X5[rank][%%A]!]+=1"
				)
				if /i "!RANKED_FLEX_SR[rank][%%A]!"=="" (
					set /a "flex[unranked]+=1"
				) else (
					set /a "flex[!RANKED_FLEX_SR[rank][%%A]!]+=1"
				)
				if !skinsamount[%%A]! equ 0 (
					set /a "skins[0]+=1"
				) else if !skinsnamount[%%A]! geq 200 (
					set /a skins[over200]+=1"
				) else if !skinsamount[%%A]! geq 151 (
					set /a skins[151to200]+=1"
				) else if !skinsamount[%%A]! geq 101 (
					set /a skins[101to150]+=1"
				) else if !skinsamount[%%A]! geq 51 (
					set /a skins[51to100]+=1"
				) else if !skinsamount[%%A]! geq 21 (
					set /a skins[21to50]+=1"
				) else if !skinsamount[%%A]! geq 1 (
					set /a skins[1to20]+=1"
				)

				if !rp[%%A]! equ 0 (
					set /a "rpo[0]+=1"
				) else if !rp[%%A]! geq 5000 (
					set /a rpo[over5000]+=1"
				) else if !rp[%%A]! geq 3000 (
					set /a rpo[3000to5000]+=1"
				) else if !rp[%%A]! geq 2000 (
					set /a rpo[2000to3000]+=1"
				) else if !rp[%%A]! geq 1000 (
					set /a rpo[1000to2000]+=1"
				) else if !rp[%%A]! geq 350 (
					set /a rpo[350to1000]+=1"
				) else if !rp[%%A]! geq 1 (
					set /a rpo[1to350]+=1"
				)
				if "!emailverified[%%A]!"=="True" set /a "verifiedmail+=1"
				if "!emailverified[%%A]!"=="False" set /a "unverifiedmail+=1"

			)
			echo=!ESC![2J!ESC![1;1H!ESC![?25l
			echo=!c!┌^(!re! Solo/Duo rank !c!│!re! Flex rank !c!^)──────────┐!re!
			echo=!c!│[!re!^>!c!]!re! Unranked    !c![!re!^>^>^>!c!]!re!  !c!^(!re! !solo[unranked]! !c!│!re! !flex[unranked]! !c!^)!re!!ESC![41G!c!│!re!
			echo=!c!│[!re!^>!c!]!re! Iron        !c![!re!^>^>^>!c!]!re!  !c!^(!re! !solo[iron]! !c!│!re! !flex[iron]! !c!^)!re!!ESC![41G!c!│!re!
			echo=!c!│[!re!^>!c!]!re! Bronze      !c![!re!^>^>^>!c!]!re!  !c!^(!re! !solo[bronze]! !c!│!re! !flex[bronze]! !c!^)!re!!ESC![41G!c!│!re!
			echo=!c!│[!re!^>!c!]!re! Silver      !c![!re!^>^>^>!c!]!re!  !c!^(!re! !solo[silver]! !c!│!re! !flex[silver]! !c!^)!re!!ESC![41G!c!│!re!
			echo=!c!│[!re!^>!c!]!re! Gold        !c![!re!^>^>^>!c!]!re!  !c!^(!re! !solo[gold]! !c!│!re! !flex[gold]! !c!^)!re!!ESC![41G!c!│!re!
			echo=!c!│[!re!^>!c!]!re! Platinum    !c![!re!^>^>^>!c!]!re!  !c!^(!re! !solo[platinum]! !c!│!re! !flex[platinum]! !c!^)!re!!ESC![41G!c!│!re!
			echo=!c!│[!re!^>!c!]!re! Emerald     !c![!re!^>^>^>!c!]!re!  !c!^(!re! !solo[emerald]! !c!│!re! !flex[emerald]! !c!^)!re!!ESC![41G!c!│!re!
			echo=!c!│[!re!^>!c!]!re! Diamond     !c![!re!^>^>^>!c!]!re!  !c!^(!re! !solo[diamond]! !c!│!re! !flex[diamond]! !c!^)!re!!ESC![41G!c!│!re!
			echo=!c!│[!re!^>!c!]!re! Master      !c![!re!^>^>^>!c!]!re!  !c!^(!re! !solo[master]! !c!│!re! !flex[master]! !c!^)!re!!ESC![41G!c!│!re!
			echo=!c!│[!re!^>!c!]!re! Grandmaster !c![!re!^>^>^>!c!]!re!  !c!^(!re! !solo[grandmaster]! !c!│!re! !flex[grandmaster]! !c!^)!re!!ESC![41G!c!│!re!
			echo=!c!│[!re!^>!c!]!re! Challenger  !c![!re!^>^>^>!c!]!re!  !c!^(!re! !solo[challenger]! !c!│!re! !flex[challenger]! !c!^)!re!!ESC![41G!c!│!re!
			echo=!c!└───────────────────────────────────────┘!re!
			echo=!c!┌^(!re! Rare Skins !c!^)─────────────────────────┐!re!
			echo=!c!│[!re!^>!c!]!re! 0    !c![!re!^>^>^>!c!]!re!  !c!^(!re! !rare_skins[0]! !c!^)!re!!ESC![41G!c!│!re!
			echo=!c!│[!re!^>!c!]!re! 1-2  !c![!re!^>^>^>!c!]!re!  !c!^(!re! !rare_skins[1to2]! !c!^)!re!!ESC![41G!c!│!re!
			echo=!c!│[!re!^>!c!]!re! 3-4  !c![!re!^>^>^>!c!]!re!  !c!^(!re! !rare_skins[3to4]! !c!^)!re!!ESC![41G!c!│!re!
			echo=!c!│[!re!^>!c!]!re! 5-6  !c![!re!^>^>^>!c!]!re!  !c!^(!re! !rare_skins[5to6]! !c!^)!re!!ESC![41G!c!│!re!
			echo=!c!│[!re!^>!c!]!re! 6+   !c![!re!^>^>^>!c!]!re!  !c!^(!re! !rare_skins[over6]! !c!^)!re!!ESC![41G!c!│!re!
			echo=!c!└───────────────────────────────────────┘!re!
			echo=!c!┌^(!re! Skins !c!^)──────────────────────────────┐!re!
			echo=!c!│[!re!^>!c!]!re! 0        !c![!re!^>^>^>!c!]!re!  !c!^(!re! !skins[0]! !c!^)!re!!ESC![41G!c!│!re!
			echo=!c!│[!re!^>!c!]!re! 1-20     !c![!re!^>^>^>!c!]!re!  !c!^(!re! !skins[1to20]! !c!^)!re!!ESC![41G!!c!│!re!
			echo=!c!│[!re!^>!c!]!re! 21-50    !c![!re!^>^>^>!c!]!re!  !c!^(!re! !skins[21to50]! !c!^)!re!!ESC![41G!!c!│!re!
			echo=!c!│[!re!^>!c!]!re! 51-100   !c![!re!^>^>^>!c!]!re!  !c!^(!re! !skins[51to100]! !c!^)!re!!ESC![41G!!c!│!re!
			echo=!c!│[!re!^>!c!]!re! 101-150  !c![!re!^>^>^>!c!]!re!  !c!^(!re! !skins[101to150]! !c!^)!re!!ESC![41G!!c!│!re!
			echo=!c!│[!re!^>!c!]!re! 151-200  !c![!re!^>^>^>!c!]!re!  !c!^(!re! !skins[151to200]! !c!^)!re!!ESC![41G!!c!│!re!
			echo=!c!│[!re!^>!c!]!re! 200+     !c![!re!^>^>^>!c!]!re!  !c!^(!re! !skins[over200]! !c!^)!re!!ESC![41G!!c!│!re!
			echo=!c!└───────────────────────────────────────┘!re!
			echo=!ESC![2;42H!c!┌^(!re! Servers !c!^)──────────────────────────┐!re!
			echo=!ESC![3;42H!c!│[!re!^>!c!]!re! VN    !c![!re!^>^>^>!c!]!re!  !c!^(!re! !region[vn]! !c!^)!re!!ESC![80G!c!│!re!
			echo=!ESC![4;42H!c!│[!re!^>!c!]!re! TR    !c![!re!^>^>^>!c!]!re!  !c!^(!re! !region[tr]! !c!^)!re!!ESC![80G!c!│!re!
			echo=!ESC![5;42H!c!│[!re!^>!c!]!re! RU    !c![!re!^>^>^>!c!]!re!  !c!^(!re! !region[ru]! !c!^)!re!!ESC![80G!c!│!re!
			echo=!ESC![6;42H!c!│[!re!^>!c!]!re! SG    !c![!re!^>^>^>!c!]!re!  !c!^(!re! !region[sg]! !c!^)!re!!ESC![80G!c!│!re!
			echo=!ESC![7;42H!c!│[!re!^>!c!]!re! NA    !c![!re!^>^>^>!c!]!re!  !c!^(!re! !region[na]! !c!^)!re!!ESC![80G!c!│!re!
			echo=!ESC![8;42H!c!│[!re!^>!c!]!re! EUW   !c![!re!^>^>^>!c!]!re!  !c!^(!re! !region[euw]! !c!^)!re!!ESC![80G!c!│!re!
			echo=!ESC![9;42H!c!│[!re!^>!c!]!re! EUNE  !c![!re!^>^>^>!c!]!re!  !c!^(!re! !region[eune]! !c!^)!re!!ESC![80G!c!│!re!
			echo=!ESC![10;42H!c!│[!re!^>!c!]!re! OCE   !c![!re!^>^>^>!c!]!re!  !c!^(!re! !region[oce]! !c!^)!re!!ESC![80G!c!│!re!
			echo=!ESC![11;42H!c!│[!re!^>!c!]!re! LAN   !c![!re!^>^>^>!c!]!re!  !c!^(!re! !region[lan]! !c!^)!re!!ESC![80G!c!│!re!
			echo=!ESC![12;42H!c!│[!re!^>!c!]!re! LAS   !c![!re!^>^>^>!c!]!re!  !c!^(!re! !region[las]! !c!^)!re!!ESC![80G!c!│!re!
			echo=!ESC![13;42H!c!│[!re!^>!c!]!re! BR    !c![!re!^>^>^>!c!]!re!  !c!^(!re! !region[br]! !c!^)!re!!ESC![80G!c!│!re!
			echo=!ESC![14;42H!c!└─────────────────────────────────────┘!re!
			echo=!ESC![15;42H!c!┌^(!re! Email Address !c!^)────────────────────┐!re!
			echo=!ESC![16;42H!c!│[!re!^>!c!]!re! Verified      !c![!re!^>^>^>!c!]!re!  !c!^(!re! !verifiedmail! !c!^)!re!!ESC![80G!c!│!re!
			echo=!ESC![17;42H!c!│[!re!^>!c!]!re! Unverified    !c![!re!^>^>^>!c!]!re!  !c!^(!re! !unverifiedmail! !c!^)!re!!ESC![80G!c!│!re!
			echo=!ESC![18;42H!!c!└─────────────────────────────────────┘!re!
			echo=!ESC![19;42H!c!┌^(!re! Imported accounts !c!^)────────────────┐!re!
			echo=!ESC![20;42H!c!│[!re!^>!c!]!re! Working       !c![!re!^>^>^>!c!]!re!  !c!^(!re! !acc! !c!^)!re!!ESC![80G!c!│!re!
			echo=!ESC![21;42H!!c!└─────────────────────────────────────┘!re!!ESC![1;1H
			echo=!ESC![22;42H!c!┌^(!re! RP !c!^)───────────────────────────────┐!re!
			echo=!ESC![23;42H!c!│[!re!^>!c!]!re! 0          !c![!re!^>^>^>!c!]!re!  !c!^(!re! !rpo[0]! !c!^)!re!!ESC![80G!c!│!re!
			echo=!ESC![24;42H!c!│[!re!^>!c!]!re! 1-350      !c![!re!^>^>^>!c!]!re!  !c!^(!re! !rpo[1to350]! !c!^)!re!!ESC![80G!!c!│!re!
			echo=!ESC![25;42H!c!│[!re!^>!c!]!re! 350-1000   !c![!re!^>^>^>!c!]!re!  !c!^(!re! !rpo[350to1000]! !c!^)!re!!ESC![80G!!c!│!re!
			echo=!ESC![26;42H!c!│[!re!^>!c!]!re! 1000-2000  !c![!re!^>^>^>!c!]!re!  !c!^(!re! !rpo[1000to2000]! !c!^)!re!!ESC![80G!!c!│!re!
			echo=!ESC![27;42H!c!│[!re!^>!c!]!re! 2000-3000  !c![!re!^>^>^>!c!]!re!  !c!^(!re! !rpo[2000to3000]! !c!^)!re!!ESC![80G!!c!│!re!
			echo=!ESC![28;42H!c!│[!re!^>!c!]!re! 3000-5000  !c![!re!^>^>^>!c!]!re!  !c!^(!re! !rpo[3000to5000]! !c!^)!re!!ESC![80G!!c!│!re!
			echo=!ESC![29;42H!c!│[!re!^>!c!]!re! 5000+      !c![!re!^>^>^>!c!]!re!  !c!^(!re! !rpo[over5000]! !c!^)!re!!ESC![80G!!c!│!re!
			echo=!ESC![30;42H!c!└─────────────────────────────────────┘!re!
			>nul pause
			echo=!ESC![2J!ESC![1;1H!ESC![?25l
			goto :disp

		)
		if !upsel!==7 (
			if "!censormode!"=="[X]" goto :disp
			chcp 437>nul
			echo=!ESC![2J!ESC![1;1H
			echo= Recovery questions are needed to attempt to recover an account, this is the most you can get while you are not the original creator.
			echo=
			echo= !sel_norm_clr!Account info!esc![0m
			echo= Username: !login[%sel%]!
			echo= Password: !password[%sel%]!
			echo= Summoner name: !summoner[%sel%]!
			echo= Email address: !email[%sel%]!
			echo= Account region: !region[%sel%]!
			echo= Account registration date: !creation_date[%sel%]!
			echo= Birth year: !birth_year[%sel%]! ^(Age: !age[%sel%]!^)
			echo= Account creation country: !parsed_country[%sel%]! ^(!creation_country[%sel%]!^)
			echo=
			echo= !sel_norm_clr!First 5 Skins:!esc![0m
			echo= !skin_name[1][%sel%]! - !skin_date[1][%sel%]!
			echo= !skin_name[2][%sel%]! - !skin_date[2][%sel%]!
			echo= !skin_name[3][%sel%]! - !skin_date[3][%sel%]!
			echo= !skin_name[4][%sel%]! - !skin_date[4][%sel%]!
			echo= !skin_name[5][%sel%]! - !skin_date[5][%sel%]!
			echo=
			echo= !sel_norm_clr!First 5 Champions:!esc![0m
			echo= !champ_name[1][%sel%]! - !champ_date[1][%sel%]!
			echo= !champ_name[2][%sel%]! - !champ_date[2][%sel%]!
			echo= !champ_name[3][%sel%]! - !champ_date[3][%sel%]!
			echo= !champ_name[4][%sel%]! - !champ_date[4][%sel%]!
			echo= !champ_name[5][%sel%]! - !champ_date[5][%sel%]!
			chcp 65001>nul
			>nul pause
			echo=!ESC![2J!ESC![1;1H
			goto :disp
		)
	


		if !upsel!==2 (
		<nul set /p=!ESC![2J
		set /a tmp_sel=1
		:file_menu
		echo=!ESC![1;1H
		echo=Copy to clipboard by pressing X^^! Note this will also erase your previous clipboard.
		echo=
		echo=Would you like to:
		if !tmp_sel! equ 1 (
			echo=!sel_norm_clr!Copy Riot Name#Riot Tag!esc![0m
		) else (
			echo=Copy Riot Name#Riot Tag
		)
		if !tmp_sel! equ 2 (
			echo=!sel_norm_clr!Copy credentials as username:password!esc![0m
		) else (
			echo=Copy credentials as username:password
		)
		if !tmp_sel! equ 3 (
			echo=!sel_norm_clr!Copy known recovery information!esc![0m
		) else (
			echo=Copy known recovery information
		)
		if !tmp_sel! equ 4 (
			echo=!sel_norm_clr!Copy Account info tab!esc![0m
		) else (
			echo=Copy Account info tab
		)
		if !tmp_sel! equ 5 (
			echo=!sel_norm_clr!Copy rare skins as RareSkin[1], RareSkin[2], ...!esc![0m
		) else (
			echo=Copy rare skins as RareSkin[1], RareSkin[2], ...
		)
		if !tmp_sel! equ 6 (
			echo=!sel_norm_clr!Copy inventory ^(skin, ward, ultimate skin, epic skin count etc.^)!esc![0m
		) else (
			echo=Copy inventory ^(skin, ward, ultimate skin, epic skin count etc.^)
		)
		if !tmp_sel! equ 7 (
			echo=!sel_norm_clr!Copy all account info in menu as Region:region,Username:username,...!esc![0m
		) else (
			echo=Copy all account info in menu as Region:region,Username:username,...
		)
		if !tmp_sel! equ 8 (
			echo=!sel_norm_clr!Copy account info for sell as Region:\nEmail verified:\nLevel:\nRP:\nBE:\nChampions:\nSkins:\nRare skins:\nLast match:\nRank:\n!esc![0m
		) else (
			echo=Copy account info for sell as Region:\nEmail verified:\nLevel:\nRP:\nBE:\nChampions:\nSkins:\nRare skins:\nLast match:\nRank:\n!esc![0m
		)
		if !tmp_sel! equ 9 (
			echo=!sel_norm_clr!Copy all champions as Champion[1], Champion[2], ...!esc![0m
		) else (
			echo=Copy all champions as Champion[1], Champion[2], ...
		)
		if !tmp_sel! equ 10 (
			echo=!sel_norm_clr!Copy all skins as Skin[1], Skin[2], ...!esc![0m
		) else (
			echo=Copy all skins as Skin[1], Skin[2], ...
		)
		if !tmp_sel! equ 11 (
			echo=!sel_norm_clr!Copy TFT Little Legends as LL[1], LL[2], ...!esc![0m
		) else (
			echo=Copy TFT Little Legends as LL[1], LL[2], ...
		)
		if !tmp_sel! equ 12 (
			echo=!sel_norm_clr!Copy TFT Booms as Booms[1], Booms[2], ...!esc![0m
		) else (
			echo=Copy TFT Booms as Booms[1], Booms[2], ...
		)
		if !tmp_sel! equ 13 (
			echo=!sel_norm_clr!Copy TFT Map Skins as MapSkin[1], MapSkin[2], ...!esc![0m
		) else (
			echo=Copy TFT Map Skins as MapSkin[1], MapSkin[2], ...!esc![0m
		)
		if !tmp_sel! equ 14 (
			echo=!sel_norm_clr!Copy OP.GG!esc![0m
		) else (
			echo=Copy OP.GG
		)
		if !tmp_sel! equ 15 (
			echo=!sel_norm_clr!Exit to main menu!esc![0m
		) else (
			echo=Exit to main menu
		)
		call :xcopy
		if /i "!key!"=="w" if not !tmp_sel! leq 1 set /a tmp_sel-=1
		if /i "!key!"=="s" if not !tmp_sel! geq 15 set /a tmp_sel+=1
		if /i "!key!"=="x" (
			if !tmp_sel! equ 1 (
				echo=!summoner[%sel%]!|clip.exe
			)
			if !tmp_sel! equ 3 (
				chcp 437>nul
				echo=Username: !login[%sel%]!!\n!Password: !password[%sel%]!!\n!Summoner name: !summoner[%sel%]!!\n!Email address: !email[%sel%]!!\n!Account region: !region[%sel%]!!\n!Account registration date ^(might be inaccurate^): !creation_date[%sel%]!!\n!Birth year: !birth_year[%sel%]! ^(Age: !age[%sel%]!^)!\n!Account creation country: !parsed_country[%sel%]! ^(!creation_country[%sel%]!^)!\n!!\n!First 3 Skins:!\n!!skin_name[1][%sel%]! - !skin_date[1][%sel%]!!\n!!skin_name[2][%sel%]! - !skin_date[2][%sel%]!!\n!!skin_name[3][%sel%]! - !skin_date[3][%sel%]!!\n!!\n!First 5 Champions:!\n!!champ_name[1][%sel%]! - !champ_date[1][%sel%]!!\n!!champ_name[2][%sel%]! - !champ_date[2][%sel%]!!\n!!champ_name[3][%sel%]! - !champ_date[3][%sel%]!!\n!!champ_name[4][%sel%]! - !champ_date[4][%sel%]!!\n!!champ_name[5][%sel%]! - !champ_date[5][%sel%]!>"tmp_copy.txt"
				chcp 65001>nul
				clip.exe<"tmp_copy.txt"
				2>nul del /f /q "tmp_copy.txt"   

			)
			if !tmp_sel! equ 4 (
				chcp 437>nul
				echo=Region: !region[%sel%]!!\n!Summoner Name: !summoner[%sel%]!!\n!Login: !login[%sel%]!!\n!Password: !password[%sel%]!!\n!Level: !level[%sel%]!!\n!Email verified: !emailverified[%sel%]!!\n!Account email: !email[%sel%]!!\n!Honor level: !honorlevel[%sel%]!!\n!Honor checkpoint: !checkpoint[%sel%]!!\n!XP Boost end date: !xp_boost[%sel%]!!\n!Ranked restriction: !rankedrestriction[%sel%]!!\n!Prime capsule count: !prime_capsules[%sel%]!!\n!Last match played: !last_match[%sel%]!!\n!Creation country: !creation_country[%sel%]!!\n!Verified phone number: !verified_number[%sel%]!!\n!Age: !age[%sel%]!!\n!Security auth: !security[%sel%]!!\n!Export date: !export_date[%sel%]!>"tmp_copy.txt"
				chcp 65001>nul
				clip.exe<"tmp_copy.txt"
				2>nul del /f /q "tmp_copy.txt"   

			)
			if !tmp_sel! equ 5 (
				set "rare_to_copy="
				for %%. in ("!sel!") do for /l %%A in (1 1 !rare[%sel%]!) do (
					set "rare_to_copy=!rare_to_copy!, !rare_skin[%%~.][%%A]!"
				)
				set "rare_to_copy=!rare_to_copy:~2,9999!"
				set "rare_to_copy=!rare_to_copy:&=^&!"
				echo=!rare_to_copy!|clip.exe
			)
			if !tmp_sel! equ 6 (
				rem === inv ===
				call :load_champ_and_skins "!sel!"
				echo=Ultimate skins: !rarity_count[%sel%][kUltimate]!!\n!Mythic skins: !rarity_count[%sel%][kMythic]!!\n!Legendary skins: !rarity_count[%sel%][kLegendary]!!\n!Epic skins: !rarity_count[%sel%][kEpic]!!\n!No rarity skins: !rarity_count[%sel%][kNoRarity]!!\n!Legacy skins: !legacy_count[%sel%][True]!!\n!Non-legacy skins: !legacy_count[%sel%][False]!!\n!RP: !rp[%sel%]!!\n!BE: !be[%sel%]!!\n!ME: !me[%sel%]!!\n!OE: !oe[%sel%]!!\n!Skin count: !skinsamount[%sel%]!!\n!Champion count: !champsamount[%sel%]!!\n!Ward skin count: !ward_count[%sel%]!!\n!Icon count: !icon_count[%sel%]!!\n!Emote count: !emote_count[%sel%]!!\n!Rune page count: !rune_page_count[%sel%]!!\n!>"tmp_copy.txt"
				clip.exe<"tmp_copy.txt"
				2>nul del /f /q "tmp_copy.txt"                
			)
			if !tmp_sel! equ 11 (
				set "ll_to_copy="
				for %%. in ("!sel!") do for /l %%A in (1 1 !tft_little_legend_count[%%~.]!) do (
					set "ll_to_copy=!ll_to_copy!, !tft_little_legend_name[%%A][%%~.]!"
				)
				set "ll_to_copy=!ll_to_copy:~2,9999!"
				set "ll_to_copy=!ll_to_copy:&=^&!"
				echo=!ll_to_copy!|clip.exe
			)
			if !tmp_sel! equ 12 (
				set "booms_to_copy="
				for %%. in ("!sel!") do for /l %%A in (1 1 !tft_booms_count[%%~.]!) do (
					set "booms_to_copy=!booms_to_copy!, !tft_booms_name[%%A][%%~.]!"
				)
				set "booms_to_copy=!booms_to_copy:~2,9999!"
				set "booms_to_copy=!booms_to_copy:&=^&!"
				echo=!booms_to_copy!|clip.exe
			)
			if !tmp_sel! equ 13 (
				set "map_to_copy="
				for %%. in ("!sel!") do for /l %%A in (1 1 !tft_map_skin_count[%%~.]!) do (
					set "map_to_copy=!map_to_copy!, !tft_map_skin_name[%%A][%%~.]!"
				)
				set "map_to_copy=!map_to_copy:~2,9999!"
				set "map_to_copy=!map_to_copy:&=^&!"
				echo=!map_to_copy!|clip.exe
			)


			if !tmp_sel! equ 15 (
				echo=!ESC![2J!ESC![1;1H
				goto :disp
			)
			if !tmp_sel! equ 2 (
				chcp 437>nul
				for %%. in ("!sel!") do echo=!login[%sel%]!:!password[%sel%]!|clip.exe
				chcp 65001>nul
			)
			if !tmp_sel! equ 7 (
				echo=Region:!region[%sel%]!, Username:!login[%sel%]!, Summoner name:!summoner[%sel%]!, Email verified:!emailverified[%sel%]!, Level:!level[%sel%]!, RP:!rp[%sel%]!, BE:!be[%sel%]!, Champions:!champsamount[%sel%]!, Skins:!skinsamount[%sel%]!, Solo/Duo Rank:!rank[solo][%sel%]!, Flex Queue Rank:!rank[flex][%sel%]!|clip.exe
			)
			if !tmp_sel! equ 8 (
				call :rare_skin_to_var
				echo=Region: !region[%sel%]!!\n!Email verified: !emailverified[%sel%]!!\n!Level: !level[%sel%]!!\n!RP: !rp[%sel%]!!\n!BE: !be[%sel%]!!\n!Champions: !champsamount[%sel%]!!\n!Skins: !skinsamount[%sel%]!!\n!Rare skins: !rare[%sel%]!!\n!Rare skin list: !rare_skin_list!!\n!Ward skins: !ward_count[%sel%]!!\n!Icon count: !icon_count[%sel%]!!\n!Emote count: !emote_count[%sel%]!!\n!Rune page count: !rune_page_count[%sel%]!!\n!Last match: !last_match[%sel%]!!\n!Solo/Duo Rank: !rank[solo][%sel%]!!\n!Flex Queue Rank: !rank[flex][%sel%]!>"tmp_copy.txt"
				clip.exe<"tmp_copy.txt"
				2>nul del /f /q "tmp_copy.txt"
			)
			if !tmp_sel! equ 9 (
				set "champion_list_to_copy="
				call :load_champ_and_skins "!sel!"
				set "tmp_var=!champsamount[%sel%]!"
				for %%. in ("!sel!") do for /l %%A in (1 1 !tmp_var!) do (
					set "champion_list_to_copy=!champion_list_to_copy!, !champ_name[%%A][%%~.]!"
				)
				set "champion_list_to_copy=!champion_list_to_copy:~2,9999!"
				set "champion_list_to_copy=!champion_list_to_copy:&=^&!"
				echo=!champion_list_to_copy!|clip.exe
			)
			if !tmp_sel! equ 10 (
				set "skin_list_to_copy="
				if !skinsamount[%sel%]! equ 0 (
					echo.The skin amount is 0.
				) else (
					call :load_champ_and_skins "!sel!"
					set "tmp_var=!skinsamount[%sel%]!"
					for %%. in ("!sel!") do for /l %%A in (1 1 !tmp_var!) do (
						set "skin_list_to_copy=!skin_list_to_copy!, !skin_name[%%A][%%~.]!"
					)
					set "skin_list_to_copy=!skin_list_to_copy:~1,9999!"
					set "skin_list_to_copy=!skin_list_to_copy:&=^&!"
					echo=!skin_list_to_copy!|clip.exe
				)
			)
			if !tmp_sel! equ 14 (
				set "rg=!region[%sel%]!"
				for %%# in (a b c d e f g h i j k l m n o p q r s t u v w x y z) do set "rg=!rg:%%#=%%#!"
				echo=https://www.op.gg/summoners/!rg!/!summoner[%sel%]:#=-!|clip.exe
			)
	)
	goto :file_menu
)

	if !upsel!==3 (
		<nul set /p=!ESC![2J
		set /a tmp_sel=1
		if "!censormode!"=="[X]" (
			title !region[%sel%]! - Censored
		) else (
			title !region[%sel%]! - !summoner[%sel%]!
		)
		:import_menu
		echo=!ESC![1;1H
		echo=Import an account so you can access its information^^!
		echo=You can check every account, but only valid ones that are not banned/suspended will get exported.
		echo=
		echo=Would you like to:
		if !tmp_sel! equ 1 (
			echo=!sel_norm_clr!Import single account with credentials!esc![0m
		) else (
			echo=Import single account with credentials
		)
		if !tmp_sel! equ 2 (
			echo=!sel_norm_clr!Import from a file as combolist!esc![0m
		) else (
			echo=Import from a file as combolist
		)
		if !tmp_sel! equ 3 (
			echo=!sel_norm_clr!Import account you are logged to currently!esc![0m
		) else (
			echo=Import account you are logged to currently
		)
		if !tmp_sel! equ 4 (
			echo=!sel_norm_clr!Exit to main menu!esc![0m
		) else (
			echo=Exit to main menu
		)
		call :xcopy
		if /i "!key!"=="w" if not !tmp_sel! leq 1 set /a tmp_sel-=1
		if /i "!key!"=="s" if not !tmp_sel! geq 4 set /a tmp_sel+=1
		if /i "!key!"=="x" (
			if "!tmp_sel!"=="4" (
				echo=!ESC![2J!ESC![1;1H
				goto :disp
			)
			if "!tmp_sel!"=="3" (
				chcp 437>nul
				echo=Exporting...
				call "modules\export.bat" openchecker "!list!" "nofolder" noterm
				if !errorlevel! equ 5 (
					echo=Account is banned/locked.
					for /f "delims=, tokens=1,2,3" %%A in ('2^>nul type "accounts\!folder!\acc_!acc_soon!\is_banned.txt"') do (
						echo=Permanently banned: %%A
						echo=Ban reason: %%B
						echo=Ban until: %%C
						>nul pause
					)
				)
				if !errorlevel! equ 0 (
					rem empty environment
					for /f "tokens=1 delims==" %%a in ('set') do (
   						set "unload=true"
       						for %%b in ( cd Path ComSpec SystemRoot temp windir systemdrive list appdata localappdata listname ) do if /i "%%a"=="%%b" set "unload=false"
       						if "!unload!"=="true" set "%%a="
   					)
					goto :restart_full

				)
			)
			
			if "!tmp_sel!"=="2" goto :check_txt
			if "!tmp_sel!"=="1" (
				set /a acc_soon=acc+=1
				set /p "combo=!ESC![?25husername:password > "
				for /f "delims=: tokens=1,2" %%A in ("!combo!") do (
					set "username=%%A"
					set "password=%%B"
				)
				echo=Logging in...!ESC![?25l
				chcp 437>nul
				call "modules\logout.bat" "!debug!"
				timeout.exe /T 3 /NOBREAK >nul
				call "modules\login.bat" "!username!" "!password!" openchecker "!debug!"
				if !errorlevel! equ 1 (
					echo=[!ESC![38;2;255;0;0mERROR!ESC![0m] Invalid credentials.
					set /a acc-=1
					set /a acc_soon-=1
					>nul pause
					echo=!ESC![2J!ESC![1;1H
				) else if !errorlevel! equ 2 (
					echo=[!ESC![38;2;255;0;0mERROR!ESC![0m] Rate limited. Use VPN or wait a bit.
					set /a acc-=1
					set /a acc_soon-=1
					>nul pause
					echo=!ESC![2J!ESC![1;1H
				) else if !errorlevel! equ 3 (
					echo=[!ESC![38;2;255;0;0mERROR!ESC![0m] Account has MFA enabled, can not be exported.
					set /a acc-=1
					set /a acc_soon-=1
					>nul pause
					echo=!ESC![2J!ESC![1;1H
				) else if !Errorlevel! equ 0 (
						echo=[!ESC![38;2;0;255;0mSUCCESS!ESC![0m] Authenticated^^!
						chcp 437>nul
						call "modules\export.bat" openchecker "!list!" "nofolder" "!username!:!password!"
						if !errorlevel! equ 5 (
							echo=Account is banned/locked.
							>nul pause
						)
						if !errorlevel! equ 0 (
							chcp 65001>nul
							set "fullspace="
							rem empty environment
							for /f "tokens=1 delims==" %%a in ('set') do (
   								set "unload=true"
       								for %%b in ( cd Path ComSpec SystemRoot temp windir systemdrive list appdata localappdata listname ) do if /i "%%a"=="%%b" set "unload=false"
       								if "!unload!"=="true" set "%%a="
   							)
							goto :restart_full
						)
				) 
			)
		)
	goto :import_menu
	)
	if !upsel!==6 (
		title Open Checker - Search through accounts
		echo=!ESC![2J!ESC![1;1H
		echo=Search using type:value_name, for example:
		echo= skin:crime city twitch
		echo= champion:annie
		echo= rank_solo:challenger
		echo= rank_flex:gold
		echo= email:true, email:false
		echo= region:euw, region:eune
		echo= tft_little_legends:default
		echo= tft_booms:noclue
		echo= tft_map_skin:default
		set /p "search=!ESC![?25hEnter search > "
		for /f "delims=: tokens=1,*" %%A in ("!search!") do (
			set "title_search=Searching for %%A - %%B"
			call :filter "%%A" "%%B"
		)
		echo=!ESC![2J!ESC![1;1H!ESC![?25l
	goto :disp
		
	)
	if !upsel!==4 (
		<nul set /p=!ESC![2J
		set /a tmp_sel=1
		if "!censormode!"=="[X]" (
			title !region[%sel%]! - Censored
		) else (
			title !region[%sel%]! - !summoner[%sel%]!
		)
		:export_menu
		echo=!ESC![1;1H
		echo=Export account^(s^) into a text file, or CSV format to put into Excel or Google sheet.
		echo=
		if !tmp_sel! equ 1 (
			echo=!sel_norm_clr!Export friend list and date of add of this account!esc![0m
		) else (
			echo=Export friend list and date of add of this account
		)
		if !tmp_sel! equ 2 (
			echo=!sel_norm_clr!Export all known info of this account!esc![0m
		) else (
			echo=Export all known info of this account
		)
		if !tmp_sel! equ 3 (
			echo=!sel_norm_clr!Export this account into desired CSV!esc![0m
		) else (
			echo=Export this account into desired CSV
		)
		if !tmp_sel! equ 4 (
			echo=!sel_norm_clr!Export all accounts in this list into desired CSV!esc![0m
		) else (
			echo=Export all accounts in this list into desired CSV
		)
		if !tmp_sel! equ 5 (
			echo=!sel_norm_clr!Export all basic recovery infos!esc![0m
		) else (
			echo=Export all basic recovery infos
		)
		if !tmp_sel! equ 6 (
			echo=!sel_norm_clr!Export all advanced recovery infos!esc![0m
		) else (
			echo=Export all advanced recovery infos
		)
		if !tmp_sel! equ 7 (
			echo=!sel_norm_clr!Export all accounts to sell!esc![0m
		) else (
			echo=Export all accounts to sell
		)
		if !tmp_sel! equ 8 (
			echo=!sel_norm_clr!Export all accounts to sell + inventory info!esc![0m
		) else (
			echo=Export all accounts to sell + inventory info
		)
		if !tmp_sel! equ 9 (
			echo=!sel_norm_clr!Export to custom TXT format!esc![0m
		) else (
			echo=Export to custom TXT format
		)
		if !tmp_sel! equ 10 (
			echo=!sel_norm_clr!Export all accounts to custom TXT format!esc![0m
		) else (
			echo=Export all accounts to custom TXT format
		)
		call :xcopy
		if /i "!key!"=="w" if not !tmp_sel! leq 1 set /a tmp_sel-=1
		if /i "!key!"=="s" if not !tmp_sel! geq 10 set /a tmp_sel+=1
		if /i "!key!"=="e" (
			echo=!ESC![2J!ESC![1;1H
			goto :disp
		)
		if /i "!key!"=="x" (

			if !tmp_sel! equ 9 call :txt_format single "%~2"
			if !tmp_sel! equ 10 call :txt_format all
			if !tmp_sel! equ 5 (
				chcp 437>nul
					pushd "%temp%"
					for /f "delims=" %%. in ('powershell.exe -file "%~dp0..\modules\DIalog_Save_As_TXT.ps1"') do (
					popd
						if /i "%%."=="error" goto :export_menu
						for /l %%A in (1 1 !acc!) do (
							(echo=-------------------------------------------------------------------------------------------
							echo=Username: !login[%%A]!
							echo=Password: !password[%%A]!
							echo=Summoner name: !summoner[%%A]!
							echo=Email address: !email[%%A]!
							echo=Account region: !region[%%A]!
							echo=Original region: !original_creation_region[%%A]!
							echo=Account registration date: !creation_date[%%A]!
							echo=Birth year: !birth_year[%%A]! ^(Age: !age[%%A]!^)
							echo=Account creation country: !parsed_country[%%A]! ^(!creation_country[%%A]!^))>>"%%~."
					)
				echo=------------------------------------------------------------------------------------------->>"%%~."
				)
				chcp 65001>nul
			)

			if !tmp_sel! equ 6 (
				chcp 437>nul
					pushd "%temp%"
					for /f "delims=" %%. in ('powershell.exe -file "%~dp0..\modules\DIalog_Save_As_TXT.ps1"') do (
					popd
						if /i "%%."=="error" goto :export_menu
						for /l %%A in (1 1 !acc!) do (
							(echo=-------------------------------------------------------------------------------------------
							echo=Username: !login[%%A]!
							echo=Password: !password[%%A]!
							echo=Summoner name: !summoner[%%A]!
							echo=Email address: !email[%%A]!
							echo=Account region: !region[%%A]!
							echo=Original region: !original_creation_region[%%A]!
							echo=Account registration date: !creation_date[%%A]!
							echo=Birth year: !birth_year[%%A]! ^(Age: !age[%%A]!^)
							echo=Account creation country: !parsed_country[%%A]! ^(!creation_country[%%A]!^)
							echo=
							echo=First 3 Skins:
							echo=!skin_name[1][%%A]! - !skin_date[1][%%A]!
							echo=!skin_name[2][%%A]! - !skin_date[2][%%A]!
							echo=!skin_name[3][%%A]! - !skin_date[3][%%A]!
							echo=
							echo=First 5 Champions:
							echo=!champ_name[1][%%A]! - !champ_date[1][%%A]!
							echo=!champ_name[2][%%A]! - !champ_date[2][%%A]!
							echo=!champ_name[3][%%A]! - !champ_date[3][%%A]!
							echo=!champ_name[4][%%A]! - !champ_date[4][%%A]!
							echo=!champ_name[5][%%A]! - !champ_date[5][%%A]!
							echo=
							echo=First TFT Items:
							echo=Map Skin: !tft_map_skin_name[1][%%A]! - !tft_map_skin_date[1][%%A]!
							echo=Booms: !tft_booms_name[1][%%A]! - !tft_booms_date[1][%%A]!
							echo=LL: !tft_little_legend_name[1][%%A]! - !tft_little_legend_date[1][%%A]!)>>"%%~."
					)
				echo=------------------------------------------------------------------------------------------->>"%%~."
				)
				chcp 65001>nul
			)
			if !tmp_sel! equ 8 (
				chcp 437>nul
					pushd "%temp%"
					for /f "delims=" %%. in ('powershell.exe -file "%~dp0..\modules\DIalog_Save_As_TXT.ps1"') do (
					popd
						if /i "%%."=="error" goto :export_menu
						for /l %%A in (1 1 !acc!) do (
							call :censor "!login[%%A]!" "censored_name"
							call :rare_skin_to_var "%%A"
							(echo=-------------------------------------------------------------------------------------------
							echo=Region: !region[%%A]!
							echo=Username: !censored_name!
							echo=Email verified: !emailverified[%%A]!
							echo=Level: !level[%%A]!
							echo=RP: !rp[%%A]!
							echo=BE: !be[%%A]!
							echo=ME: !me[%%A]!
							echo=OE: !oe[%%A]!
							echo=Champions: !champsamount[%%A]!
							echo=Skins: !skinsamount[%%A]!
							echo=Ultimate skins: !rarity_count[%%A][kUltimate]!
							echo=Mythic skins: !rarity_count[%%A][kMythic]!
							echo=Legendary skins: !rarity_count[%%A][kLegendary]!
							echo=Epic skins: !rarity_count[%%A][kEpic]!
							echo=No rarity skins: !rarity_count[%%A][kNoRarity]!
							echo=Legacy skins: !legacy_count[%%A][True]!
							echo=Non-legacy skins: !legacy_count[%%A][False]!
							echo=Rare skins: !rare[%%A]!
							echo=Rare skin list: !rare_skin_list!
							echo=Ward skins: !ward_count[%%A]!
							echo=Icon count: !icon_count[%%A]!
							echo=Emote count: !emote_count[%%A]!
							echo=Rune page count: !rune_page_count[%%A]!
							echo=Last match: !last_match[%%A]!
							echo=Solo/Duo rank: !rank[solo][%%A]!
							echo=Flex Queue rank: !rank[flex][%%A]!)>>"%%~."
					)
				echo=------------------------------------------------------------------------------------------->>"%%~."
				)
				chcp 65001>nul
			)
			if !tmp_sel! equ 7 (
				chcp 437>nul
					pushd "%temp%
					for /f "delims=" %%. in ('powershell.exe -file "%~dp0..\modules\DIalog_Save_As_TXT.ps1"') do (
					popd
						if /i "%%."=="error" goto :export_menu
						for /l %%A in (1 1 !acc!) do (
							call :censor "!login[%%A]!" "censored_name"
							call :rare_skin_to_var "%%A"
							(echo=-------------------------------------------------------------------------------------------
							echo=Region: !region[%%A]!
							echo=Username: !censored_name!
							echo=Email verified: !emailverified[%%A]!
							echo=Level: !level[%%A]!
							echo=RP: !rp[%%A]!
							echo=BE: !be[%%A]!
							echo=Champions: !champsamount[%%A]!
							echo=Skins: !skinsamount[%%A]!
							echo=Rare skins: !rare[%%A]!
							echo=Rare skin list: !rare_skin_list!
							echo=Ward skins: !ward_count[%%A]!
							echo=Icon count: !icon_count[%%A]!
							echo=Emote count: !emote_count[%%A]!
							echo=Rune page count: !rune_page_count[%%A]!
							echo=Last match: !last_match[%%A]!
							echo=Solo/Duo rank: !rank[solo][%%A]!
							echo=Flex Queue rank: !rank[flex][%%A]!)>>"%%~."
					)
				echo=------------------------------------------------------------------------------------------->>"%%~."
				)
				chcp 65001>nul
			)




			if !tmp_sel! equ 3 (
				chcp 437>nul
				call :list_csv
				for /f "delims=" %%. in ('powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $dialog = New-Object System.Windows.Forms.SaveFileDialog; $dialog.Filter = 'CSV files (*.csv)|*.csv'; $dialog.ShowDialog() | Out-Null; Write-Output $dialog.FileName"') do call :csv_parse "default" "!sel!" "%%~." "alone"
				chcp 65001>nul

			)
			if !tmp_sel! equ 4 (
				chcp 437>nul
				call :list_csv
				for /f "delims=" %%. in ('powershell -Command "Add-Type -AssemblyName System.Windows.Forms; $dialog = New-Object System.Windows.Forms.SaveFileDialog; $dialog.Filter = 'CSV files (*.csv)|*.csv'; $dialog.ShowDialog() | Out-Null; Write-Output $dialog.FileName"') do for /l %%A in (1 1 !acc!) do (
					call :csv_parse "all" "%%~A" "%%~."
				)
				chcp 65001>nul
			)
			
			if !tmp_sel! equ 1 (
				chcp 437>nul
				for /f "delims=" %%. in ('powershell.exe -file "modules\DIalog_Save_As_TXT.ps1"') do (
					if /i "%%."=="error" goto :export_menu		
					for %%# in ("!sel!") do for /l %%A in (1 1 !friendscount[%%~#]!) do (
						echo=!friend_name[%%A][%%~#]! - Friends since !friend_date[%%A][%%~#]!>>"%%."
					)
				)
				chcp 65001>nul
			)

			if !tmp_sel! equ 2 (
				chcp 437>nul
				for /f "delims=" %%. in ('powershell.exe -file "modules\DIalog_Save_As_TXT.ps1"') do (
				if /i "%%."=="error" goto :export_menu
				echo==== Account info ===>>"%%."
				echo print acc info %%.
					(
						echo=Region: !region[%sel%]!
						echo=Summoner Name: !summoner[%sel%]!
						echo=Username: !login[%sel%]!	
						echo=Password: !password[%sel%]!
						echo=Level: !level[%sel%]!
						echo=Email verified: !emailverified[%sel%]!
						echo=Account email: !email[%sel%]!
						echo=Creation date: !creation_date[%sel%]!
						echo=Last password change: !password_change_date[%sel%]!

						echo=Creation country: !parsed_country[%sel%]! ^(!creation_country[%sel%]!^)
						echo=Verified phone num?: !verified_number[%sel%]!
						echo=Age ^(birth year^): !age[%sel%]! ^(!birth_year[%sel%]!^)
						echo=Security auth: !security[%sel%]!
						echo=Account ID: !accountid[%sel%]!
						echo=Summoner ID: !summonerid[%sel%]!
						echo=Puuid: !puuid[%sel%]!
						echo=Exported at: !export_date[%sel%]!
						echo=
						echo==== LoL info ===
						echo=Ranked restriction: !rankedrestriction[%sel%]!
						echo=Prime capsule count: !prime_capsules[%sel%]!
						echo=Honor level: !honorlevel[%sel%]!
						echo=Honor checkpoint: !checkpoint[%sel%]!
						echo=XP boost end date: !xp_boost[%sel%]!
						echo=Last match played: !last_match[%sel%]!

					)>>"%%."
					echo=>>"%%."
					echo==== Owned champions ===>>"%%."
					for %%# in ("!sel!") do for /l %%A in (1 1 !champsamount[%%~#]!) do (
						echo=!champ_date[%%A][%%~#]! - !champ_name[%%A][%%~#]!>>"%%~."
					)
					echo=>>"%%."

					echo==== Owned skins ===>>"%%."
					for %%# in ("!sel!") do for /l %%A in (1 1 !skinsamount[%%~#]!) do (
						echo=!skin_date[%%A][%%~#]! - !skin_name[%%A][%%~#]!>>"%%~."
					)
					echo=>>"%%."

					echo==== Friend list ===>>"%%."
					for %%# in ("!sel!") do for /l %%A in (1 1 !friendscount[%%~#]!) do (
						echo=!friend_date[%%A][%%~#]! - !friend_name[%%A][%%~#]:_= !>>"%%."
					)
					echo=>>"%%."

					echo==== Icons list ===>>"%%."
					for %%# in ("!sel!") do for /l %%A in (1 1 !icons[%%~#]!) do (
						echo=!icon_date[%%A][%%~#]! - !icon_name[%%A][%%~#]!>>"%%."
					)
					echo=>>"%%."
					echo==== Owned TFT Little Legends ===>>"%%."
					for %%# in ("!sel!") do for /l %%A in (1 1 !tft_little_legend_count[%%~#]!) do echo=!tft_little_legend_date[%%A][%%~#]! - !tft_little_legend_name[%%A][%%~#]!>>"%%." 
					echo=>>"%%."
					echo==== Owned TFT Map Skins ===>>"%%." 
					for %%# in ("!sel!") do for /l %%A in (1 1 !tft_map_skin_count[%%~#]!) do echo=!tft_map_skin_date[%%A][%%~#]! - !tft_map_skin_name[%%A][%%~#]!>>"%%." 
					echo=>>"%%."
					echo==== Owned TFT Booms ===>>"%%." 
					for %%# in ("!sel!") do for /l %%A in (1 1 !tft_booms_count[%%~#]!) do echo=!tft_booms_date[%%A][%%~#]! - !tft_booms_name[%%A][%%~#]!>>"%%." 
				)
				chcp 65001>nul
			)

		)
	goto :export_menu
	)
	if !upsel!==5 (
		<nul set /p=!ESC![2J
		set /a tmp_sel=1
		title Open Checker - Settings
		:settings_menu
		echo=!ESC![1;1H
		echo=Imported settings from "!settings!"
		echo=To edit a value, press X, to exit press E
		echo=To increase/decrease a color, press A or D
		echo=
		echo=!ESC![38;2;!r!;!g!;!b!mThis is a text color example.!ESC![0m
		echo=!ESC![48;2;!r!;!g!;!b!mThis is a background text color example.!ESC![0m
		echo=
		if !tmp_sel! equ 1 (
			echo=!sel_norm_clr!LeagueClient.exe path!ESC![0m!ESC![30G!league_client!
		) else (
			echo=LeagueClient.exe path!ESC![30G!league_client!
		)
		if !tmp_sel! equ 2 (
			echo=!sel_norm_clr!RiotClientServices.exe path!ESC![0m!ESC![30G!riot_client_services!
		) else (
			echo=RiotClientServices.exe path!ESC![30G!riot_client_services!
		)
		if !tmp_sel! equ 3 (
			echo=!sel_norm_clr!Red!ESC![0m!ESC![30G!r!  
		) else (
			echo=Red!ESC![30G!r!                
		)
		if !tmp_sel! equ 4 (
			echo=!sel_norm_clr!Green!ESC![0m!ESC![30G!g!  
		) else (
			echo=Green!ESC![30G!g!              
		)
		if !tmp_sel! equ 5 (
			echo=!sel_norm_clr!Blue!ESC![0m!ESC![30G!b!  
		) else (
			echo=Blue!ESC![30G!b!              
		)
		if !tmp_sel! equ 6 (
			echo=!sel_norm_clr!Hide sensitive information!ESC![0m!ESC![30G!censormode!
		) else (
			echo=Hide sensitive information!ESC![30G!censormode!
		)
		if !tmp_sel! equ 7 (
			echo=!sel_norm_clr!Debug mode!ESC![0m!ESC![30G!debug!
		) else (
			echo=Debug mode!ESC![30G!debug!
		)
		if !tmp_sel! equ 8 (
			echo=!sel_norm_clr!Edit CSV export formats!ESC![0m
		) else (
			echo=Edit CSV export formats
		)
		if !tmp_sel! equ 9 (
			echo=!sel_norm_clr!Rare skin list!ESC![0m!ESC![30G!rare_skins!
		) else (
			echo=Rare skin list!ESC![30G!rare_skins!
		)
		call :xcopy
		if /i "!key!"=="w" if not !tmp_sel! leq 1 set /a tmp_sel-=1
		if /i "!key!"=="s" if not !tmp_sel! geq 9 set /a tmp_sel+=1
		if /i "!key!"=="a" (
			if !tmp_sel! equ 3 (
				if not !r! equ 0 set /a r-=1
			)
			if !tmp_sel! equ 4 (
				if not !g! equ 0 set /a g-=1
			)
			if !tmp_sel! equ 5 (
				if not !b! equ 0 set /a b-=1
			)
		)
		if /i "!key!"=="d" (
			if !tmp_sel! equ 3 (
				if not !r! equ 255 set /a r+=1
			)
			if !tmp_sel! equ 4 (
				if not !g! equ 255 set /a g+=1
			)
			if !tmp_sel! equ 5 (
				if not !b! equ 255 set /a b+=1
			)
		)
		if /i "!key!"=="e" (
			echo=!ESC![2J!ESC![1;1H
			echo=Save the settings or do not save? [Y/N]
			call :xcopy
			if /i "!key!"=="y" (
				2>nul >nul del /f /q "!settings!"
				(
				echo=league_client=!league_client!
				echo=riot_client_services=!riot_client_services!
				echo=r=!r!
				echo=g=!g!
				echo=b=!b!
				echo=censormode=!censormode!
				echo=debug=!debug!
				)>>"!settings!"
				set "starting_bar=echo=!ESC![1;7H!ESC![38;5;241mPress V to change list!ESC![0m!ESC![?25l!ESC![1;36HList!ESC![1;42HCopy!ESC![1;48HImport!ESC![1;56HExport!ESC![1;64HSettings!ESC![1;74HSearch!esc![1;82HRecovery info!ESC![2;1H"
				call :set_settings
			) else call :set_settings
			goto :disp
		)
		if /i "!key!"=="x" (
			if !tmp_sel! equ 8 (
				:refresh_csv
				<nul set /p=!ESC![2J!ESC![1;1H
				set st=0
				set sel_format=1
				for /f "delims=" %%A in ('dir /b "!settings_folder!\format*"') do (
					for /f "tokens=1,2 delims=_" %%B in ("%%A") do (
						set /a st+=1
						set "select[!st!]=%%~nC"
					)
				)
				:list_csv_loop
				echo=!ESC![1;1H
				echo=Please select a format to edit by pressing X
				echo=To add a format press C, to delete a format press V
				echo=To exit press E.
				for /l %%A in (1 1 !st!) do (
					if !sel_format! equ %%A (
						echo=!sel_norm_clr!!select[%%A]!!ESC![0m  
					) else (
						echo=!select[%%A]!       
					)
				)
				call :xcopy
				if "!key!"=="e" (
					echo=!ESC![2J!ESC![1;1H
					goto :disp
				)
				if "!key!"=="w" if not !sel_format! equ 1 set /a sel_format-=1
				if "!key!"=="s" if not !sel_format! equ !st! set /a sel_format+=1
				if "!key!"=="x" (
					set "selected_format=!settings_folder!\format_!select[%sel_format%]!.txt"
					notepad.exe "!selected_format!"
					echo=
					echo=When you are done, save the file and close the text file.
					echo=All formats must be separated with ;
					echo=All format names must be surrounded by "
					echo=Example: "{Summoner name}";"{Password}"
					>nul pause
					goto :refresh_csv
				)
				if "!key!"=="c" (
					set /p "format_name=Type the new format name: "
					echo=>"!settings_folder!\format_!format_name!.txt"
					goto :refresh_csv
				)
				if "!key!"=="v" (
					set /p "format_name=Type the format name you want to delete: "
					2>nul >nul del /f /q "!settings_folder!\format_!format_name!.txt
					goto :refresh_csv
				)
				goto :list_csv_loop

			)
			if !tmp_sel! equ 1 (
				echo=Default LeagueClient.exe path is "!systemdrive!\Riot Games\League of Legends\LeagueClient.exe"
				>nul chcp 437
				for /f "delims=" %%A in ('powershell.exe -command "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') > $null; $dialog = New-Object System.Windows.Forms.OpenFileDialog; $dialog.InitialDirectory = [System.Environment]::GetFolderPath('Desktop'); $dialog.Filter = 'Executable files (*.exe)|*.exe'; if ($dialog.ShowDialog() -eq 'OK') { Write-Output $dialog.FileName }"') do set "league_client=%%A"
				>nul chcp 65001
				if not exist "!league_client!" (
					echo=[!ESC![38;2;255;0;0mERROR!ESC![0m] Path not found.
					>nul pause
					echo=!ESC![2J!ESC![1;1H
					goto :settings_menu
				)
				call :settings "league_client" "!league_client!"
				echo=!ESC![2J!ESC![1;1H
			)
			if !tmp_sel! equ 2 (
				echo=Default RiotClientServices.exe path is "!systemdrive!\Riot Games\Riot Client\RiotClientServices.exe" 
				>nul chcp 437
				for /f "delims=" %%A in ('powershell.exe -command "[System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms') > $null; $dialog = New-Object System.Windows.Forms.OpenFileDialog; $dialog.InitialDirectory = [System.Environment]::GetFolderPath('Desktop'); $dialog.Filter = 'Executable files (*.exe)|*.exe'; if ($dialog.ShowDialog() -eq 'OK') { Write-Output $dialog.FileName }"') do set "riot_client_services=%%A"
				>nul chcp 65001
				if not exist "!riot_client_services!" (
					echo=[!ESC![38;2;255;0;0mERROR!ESC![0m] Path not found.
					>nul pause
					echo=!ESC![2J!ESC![1;1H
					goto :settings_menu
				)
				call :settings "riot_client_services" "!riot_client_services!"
				echo=!ESC![2J!ESC![1;1H
			)
			if !tmp_sel! equ 9 (
				echo=!ESC![2J
				call :settings_rare
			)
			if !tmp_sel! equ 6 (
				if "!censormode!"=="[ ]" (
					set "censormode=[X]"
					set "censor_clr=!ESC![30m"
					set "censor_clr=!ESC![38;2;255;255;255m"	
				) else (
					set "censormode=[ ]"
					set "censor_clr="
				)
			)
			
			if !tmp_sel! equ 7 (
				if "!debug!"=="[ ]" (
					set "debug=[X]"
				) else (
					set "debug=[ ]"
				)
			)
		


		)
		
	)
	goto :settings_menu
)



	rem echo=!ESC![2J!ESC![1;1H
	rem chcp 65001>nul

set "starting_bar=!starting_bar:%sel_norm_clr%%option%%ESC%[0m=%option%!"
set option=!opt[%upsel%]!
set "starting_bar=!starting_bar:%option%=%sel_norm_clr%%option%%ESC%[0m!"

if /i "!key!"=="r" (
	start "%~dp0modules\main.ico" cmd /c "%~0" pressr
)
goto :choice_repeat

:check_txt
chcp 437>nul
for /f "delims=" %%A in ('powershell.exe -file "modules\Select_TXT_In_Explorer.ps1"') do set "txt_file=%%A"
chcp 65001>nul
echo=Delimeter must be ":"
choice /c:yn /m "Export into checker aswell, or just check if valid?"
if !errorlevel! equ 1 set "export_checker=true"
if !errorlevel! equ 2 set "export_checker=false"
set valid=0
set invalid=0
set banned=0
set mfa=0
set /a acc_to_check=0
for /f "delims=" %%A in ('type "!txt_file!"') do set /a acc_to_check+=1
for /f "delims=: tokens=1,2" %%B in ('type "!txt_file!"') do (
	set /a acc_soon=acc+=1
	set "username=%%B"
	set "password=%%C"
	set /a remaining=acc_to_check - acc
	set /a checked=valid + invalid + banned + mfa
	set /a remaining=acc_to_check - checked
	echo=!ESC![2J!ESC![1;1HAccount:             !username!
	echo=Checked accounts:    !checked!
	echo=Remaining accounts:  !remaining!
	echo=
	echo=Valid accounts:      !valid!
	echo=Invalid accounts:    !invalid!
	echo=Banned accounts:     !banned!
	echo=MFA accounts:        !mfa!
	echo=
	chcp 437>nul
	call "modules\logout.bat" "!debug!"
	timeout.exe /T 3 /NOBREAK >nul
	call "modules\login.bat" "!username!" "!password!" openchecker "!debug!" "!proxy_srv!"
	if !errorlevel! equ 1 (
		echo=[!ESC![38;2;255;0;0mERROR!ESC![0m] Invalid credentials.
		set /a invalid+=1
		echo=[INVALID CREDENTIALS] !username!:!password!>>"checked_accounts.txt"
		set /a acc-=1
		set /a acc_soon-=1
	) else if !errorlevel! equ 2 (
		echo=Rate limited, pausing checking accounts.>>"checked_accounts.txt"
		echo=
		powershell -Command "Add-Type -AssemblyName System.Windows.Forms; [System.Windows.Forms.MessageBox]::Show('You have been rate limited, please check the main window.', 'Open Checker', [System.Windows.Forms.MessageBoxButtons]::OK, [System.Windows.Forms.MessageBoxIcon]::Error)"
		echo=!ESC![1;31mRate limited, stopping checking accounts, please swap to different IP Adress or close this window.
		echo=If you have swapped IPs, just press any key to continue checking.!ESC![0m
		set /a acc-=1
		set /a acc_soon-=1
		pause >nul
	) else if !errorlevel! equ 3 (
		set /a mfa+=1
		echo=[!ESC![38;2;255;0;0mERROR!ESC![0m] Account has MFA enabled, can not be exported.
		echo=[MFA ENABLED] !username!:!password!>>"checked_accounts.txt"
		set /a acc-=1
		set /a acc_soon-=1
	) else if !errorlevel! equ 4 (
		echo=Rate limited or malformed request. [513]>>"checked_accounts.txt"
		echo=Rate limited or malformed request. [513]
		set exportchecker=true
		set errorlevel=0
	) else if !Errorlevel! equ 0 (
		chcp 437>nul
		if "!export_checker!"=="true" (
			call "modules\export.bat" openchecker "!list!" "nofolder" "!username!:!password!"
			if !errorlevel! equ 5 (
				set /a banned+=1
				for /f "delims=, tokens=1,2,3" %%A in ('type "accounts\!folder!\acc_!acc_soon!\is_banned.txt"') do (
					echo=[BANNED] !username!:!password! - Permanent? %%A, Reason: %%B, Ban until: %%C>>"checked_accounts.txt"
				)
			)
			if !errorlevel! equ 0 (
				set /a valid+=1
				powershell -file "modules\code.ps1" encode "!password!" "accounts\!folder!\acc_!acc_soon!\encodedPassword.txt"
				echo=[AUTHENTICATED] Exported !username!:!password!>>"checked_accounts.txt"
				echo=[!ESC![38;2;0;255;0mSUCCESS!ESC![0m] Authenticated^^!
				chcp 65001>nul
				set "fullspace="
			)
		)
		if "!export_checker!"=="false" (
			set /a valid+=1
			set /a acc-=1
			set /a acc_soon-=1
			echo=[AUTHENTICATED] !username!:!password!>>"checked_accounts.txt"
			)
		)
	)
) 
echo=
echo=!ESC![2J!ESC![1;1H
echo=Checking has finished!
echo=
echo=Valid accounts:         !valid!
echo=Invalid accounts:       !invalid!
echo=Banned/Locked accounts: !banned!
echo=MFA enabled accounts:   !mfa!
(
echo=
echo=Checking has finished!
echo=
echo=Valid accounts:         !valid!
echo=Invalid accounts:       !invalid!
echo=Banned/Locked accounts: !banned!
echo=MFA enabled accounts:   !mfa!
)>>"checked_accounts.txt"
pause >nul
set "fullspace="
endlocal
start /b "" "%~f0"
exit /b


:load_champ_and_skins
set skinl=0
set champl=0
if not defined skin_name[1][%~1] (
	for /f "delims=, tokens=1,2,3,4" %%A In ('type "accounts\!folder!\acc_%~1\account_skins.txt"') do (
	set /a skinl+=1
	set "skin_name[!skinl!][%~1]=%%A"
	set "skin_date[!skinl!][%~1]=%%B"
	set "skin_islegacy[!skinl!][%~1]=%%C"
	set "skin_rarity[!skinl!][%~1]=%%D"
	set /a "rarity_count[%~1][%%D]+=1"
	set /a "legacy_count[%~1][%%C]+=1"
)
for %%A in (legendary mythic norarity epic rare ultimate) do (
	if /i "!rarity_count[%~1][k%%A]!"=="" (
		set "rarity_count[%~1][k%%A]=0"
	)
)
if "!legacy_count[%~1][True]!"=="" set "legacy_count[%~1][True]=0"
if "!legacy_count[%~1][False]!"=="" set "legacy_count[%~1][False]=0"
)
if not defined champ_name[1][%~1] for /f "delims=, tokens=1,2" %%A In ('type "accounts\!folder!\acc_%~1\user_champions.txt"') do (
	set /a champl+=1
	set "champ_name[!champl!][%~1]=%%A"
	set "champ_date[!champl!][%~1]=%%B
)
exit /b 0

:filter <type> <value>
cd /d "%~dp0.."
for /l %%A in (1 1 !nloop!) do (
	set "number[%%A]="
	set "nj[%%A]="
)
set "nj_sel="
set "nums="
set "number_jump="
set "latest_acc_to_disp="
set "tmp_n="
echo=!ESC![2J!ESC![1;1H
set /a acc_count=!acc!
set /a acc_loop=0
set "acc_to_disp="

set "type=%~1"
set "value=%~2"
for /F "delims== tokens=1,2" %%A in ('findstr.exe /I /C:"!value!" "!list!"') do (
	for /f "delims=[] tokens=1,2,3" %%B in ("%%A") do (
		if "%%~B"=="!type!" (
			if "%%~D"=="" (
				set "acc_to_disp=!acc_to_disp!,%%C"
			) else (
				set "acc_to_disp=!acc_to_disp!,%%D"
			)
		)
	)
)
echo !acc_to_disp!
set "nums=!acc_to_disp:,= !"
set /a nloop=0
set /a number_jump=0
for %%A in (!nums!) do (
	set /a nloop+=1
	set "number[!nloop!]=%%A
)
set /a amount_of_loops=nloop-1
for /l %%A in (1 1 !amount_of_loops!) do (
	set /a number_jump=%%A+1
	set /a tmp_n=%%A+1
	for %%. in ("!tmp_n!") do set /a "nj[%%A]=!number[%%~.]!-!number[%%A]!"
)
for /l %%A in (1 1 !nloop!) do echo.number[%%A]=!number[%%A]!
echo !acc_to_disp!
for /l %%A in (1 1 !nloop!) do echo.summoner[%%A]=!summoner[%%A]!
set "nj_sel=!nj[1]!"
set sel=1
set search=true
popd
exit /b 0

:settings <valueName> <valueData>
for /f "delims== tokens=1,2" %%A in ('2^>nul type "!settings!"') do (
	if "%%~A"=="%~1" (
		echo=%%~A=%~2>>"!settings_folder!\settings_new.txt"
	) else (
		echo=%%~A=%%~B>>"!settings_folder!\settings_new.txt"
	)
)
del /f /q "!settings!"
rename "!settings_folder!\settings_new.txt" "settings.txt"
call :set_settings
exit /b 0

:settings_rare
echo=!ESC![1;1H
echo=All skins must be separated by ,
echo=Press {ENTER} to save, press {TAB} to exit
echo=
echo=!ESC![?25h!rare_skins!                                                                   
set "key="
for /f "delims=" %%A in ('xcopy /w "%~f0" "%~f0" 2^>nul') do (
	if not defined key set "key=%%A^!"
)
if !key:~-1!==^^ (
	set "key=^"
) else set "key=!key:~-2,1!"
if !key! equ !\r! set "key={Enter}"

if /i "!Key!"=="{Enter}" (
	set "rare_skins="!rare_skins:, =" "!"
	del /f /q "!settings_folder!\rare_skins.txt" 2>nul >nul
	for %%A in (!rare_skins!) do echo=%%~A>>"!settings_folder!\rare_skins.txt"
	echo=New settings were saved^!
	>nul pause
	echo=!ESC![2J!ESC![1;1H
	call :set_settings
	goto :settings_menu
)
if "!key!"=="	" (
	echo=!ESC![2J!ESC![1;1H
	goto :settings_menu
)
if "!key!"=="!BS!" (
	set /a len-=1
	set "rare_skins=!rare_skins:~0,-1!"
) else (
	set /a len+=1
	set "rare_skins=!rare_skins!!key!"
)
goto :settings_rare

:set_settings
for /f "delims=" %%E in (
    'forfiles /p "%~dp0." /m "%~nx0" /c "cmd /c echo(0x1B"'
) do (
    set "ESC=%%E"
)
set "rare_skins="
for /f "delims=" %%A in (!settings_folder!\rare_skins.txt) do (
	set "rare_skins=!rare_skins!, %%A"
)
for /f "delims=" %%A in (!settings!) do set "%%A"
set "sel_clr=!ESC![48;2;!r!;!g!;!b!m"
set "sel_norm_clr=!ESC![38;2;!r!;!g!;!b!m"
if "!censormode!"=="[ ]" (
	set "censor_clr="
) else set "censor_clr=!ESC![30m"
set "rare_skins=!rare_skins:~2,9999!"
exit /b 0


:rare_skin_to_var
if not "%~1"=="" (
	set "tmpsel=%~1"
) else set tmpsel=!sel!
set rare_skin_list=
for %%B in ("!tmpsel!") do for /l %%A in (1 1 !rare[%%~B]!) do (
	set "rare_skin_list=!rare_skin_list!, !rare_skin[%%~B][%%A]!"
)
if not "!rare_skin_list!"=="" (
	set "rare_skin_list=!rare_skin_list:~2,9999!"
) else (
	set "rare_skin_list=None"
)
exit /b 0

:get_rc <>
for /f "tokens=1,2" %%A in ('curl.exe --silent "http://worldtimeapi.org/api/timezone/Europe/London.txt"') do (
	if "%%A"=="utc_datetime:" (
		for /f "tokens=1 delims=-" %%C in ("%%B") do (
			set /a "birth_year=%%C - age[!sel!]"
		)
	)
)
if not "%~2"=="dontsave" (
	for /f "delims=" %%A in ('curl.exe --silent  "https://restcountries.com/v3.1/alpha/!creation_country[%sel%]!?fields=name"') do (
		set "json_country=%%A"
	)
	set "json_country=!json_country:"=\"!"
	for /f "delims=" %%A in ('powershell -Command "$json = ConvertFrom-Json '!json_country!'; $officialName = $json.name.official; Write-Output $officialName"') do set "creation_country=%%A"
)
set rcs=0
set rcc=0
for /f "delims=, tokens=1,2" %%A in ('powershell.exe -Command "$data = Get-Content 'accounts\!folder!\acc_!sel!\account_skins.txt'; $objects = $data | ForEach-Object { $split = $_ -split ','; [PSCustomObject]@{ Name = $split[0]; ObtainDate = [datetime]::ParseExact($split[1],'yyyy-MM-dd HH:mm:ss', $null)} }; $sorted = $objects | Sort-Object ObtainDate; $firstThree = $sorted | Select-Object -First 3; $firstThree | ForEach-Object { Write-Output ($_.Name + ', ' + $_.ObtainDate.ToString('yyyy-MM-dd HH:mm:ss')) }"') do (
	set /a rcs+=1
	set "rc_skin_name[!rcs!]=%%A"
	set "rc_skin_date[!rcs!]=%%B"
)
for /f "delims=, tokens=1,2" %%A in ('powershell -Command "$data = Get-Content 'accounts\!folder!\acc_!sel!\user_champions.txt'; $objects = $data | ForEach-Object { $split = $_ -split ','; [PSCustomObject]@{ Champion = $split[0]; ObtainDate = [datetime]::ParseExact($split[1], 'yyyy-MM-dd', $null)} }; $sorted = $objects | Sort-Object ObtainDate; $firstFive = $sorted | Select-Object -First 5; $firstFive | ForEach-Object { Write-Output ($_.Champion + ', ' + $_.ObtainDate.ToString('yyyy-MM-dd')) }"
') do (
	set /a rcc+=1
	set "rc_champ_name[!rcc!]=%%A"
	set "rc_champ_date[!rcc!]=%%B"
)
if "%~2"=="dontsave" exit /b 0
(
echo=registration_date=!rc_champ_date[1]!
echo=birth_year=!birth_year!
echo=creation_country=!creation_country!
echo=rc_skin_name[1]=!rc_skin_name[1]!
echo=rc_skin_name[2]=!rc_skin_name[2]!
echo=rc_skin_name[3]=!rc_skin_name[3]!
echo=rc_skin_date[1]=!rc_skin_date[1]!
echo=rc_skin_date[2]=!rc_skin_date[2]!
echo=rc_skin_date[3]=!rc_skin_date[3]!
echo=rc_champ_name[1]=!rc_champ_name[1]!
echo=rc_champ_name[2]=!rc_champ_name[2]!
echo=rc_champ_name[3]=!rc_champ_name[3]!
echo=rc_champ_name[4]=!rc_champ_name[4]!
echo=rc_champ_name[5]=!rc_champ_name[5]!
echo=rc_champ_date[1]=!rc_champ_date[1]!
echo=rc_champ_date[2]=!rc_champ_date[2]!
echo=rc_champ_date[3]=!rc_champ_date[3]!
echo=rc_champ_date[4]=!rc_champ_date[4]!
echo=rc_champ_date[5]=!rc_champ_date[5]!
)>>"accounts\!folder!\acc_!sel!\rc_info.txt"
exit /b 0

:csv_parse
call :value_convert "." "%~2"
set "index=%~2"
set "form_csv="
set "line="
set /a format_count=0
for /f "delims=" %%A in ('type "!selected_format!"') do (
	set "line=%%A"
	set "line=!line:;= !"
	for %%B in (%%A) do (
		set /a format_count+=1
		set "format[!format_count!]=%%~B"
	)
)
for /l %%A in (1 1 !format_count!) do (
	set "format[%%A]=!format[%%A]:{=!"
	set "format[%%A]=!format[%%A]:}=!"
	set "form_csv=!form_csv!,"!format[%%A]!""
)

set "form_csv=!form_csv:~1,9999!"
echo Exported %~2 ^(!login[%~2]!^)
if "%~4"=="alone" (
	echo=!form_csv!>"%~3"
) else (
	if "%~2"=="1" echo=!form_csv!>"%~3"
)
echo=%form_csv:"=^!%>>"%~3"
exit /b 0

:list_csv
<nul set /p=!ESC![2J!ESC![1;1H
set st=0
set sel_format=1
for /f "delims=" %%A in ('dir /b "!settings_folder!\format*"') do (
	for /f "tokens=1,2 delims=_" %%B in ("%%A") do (
		set /a st+=1
		set "select[!st!]=%%~nC"
	)
)
:tmp
echo=!ESC![1;1H!ESC![2J
echo=Please select a format to export in your account^(s^):
for /l %%A in (1 1 !st!) do (
	if !sel_format! equ %%A (
		echo=!sel_norm_clr!!select[%%A]!!ESC![0m  
	) else (
		echo=!select[%%A]!       
	)
)
call :xcopy
if "!key!"=="w" if not !sel_format! equ 1 set /a sel_format-=1
if "!key!"=="s" if not !sel_format! equ !st! set /a sel_format+=1
if "!key!"=="x" (
	<nul set /p=!ESC![2J!ESC![1;1H
	set "selected_format=!settings_folder!\format_!select[%sel_format%]!.txt"
	exit /b 0
)
goto :tmp

:get_patch
set "patch_url=https://ddragon.leagueoflegends.com/api/versions.json"
for /f "delims=" %%A in ('curl.exe -s -X GET "!patch_url!"') do (
	set "result=%%A"
	set "result=!result:"= !"
	set "result=!result:[= !"
	set "result=!result:]= !"
	set "result=!result:,= !"
	for %%B in (!result!) do (
		set "latest_patch=%%~B"
		exit /b 0
	)
)

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

:xcopy
)
set "key="
setlocal DisableDelayedExpansion
for /f "delims=" %%C in ('2^>nul xcopy.exe /w /l "%~f0" "%~f0"') do if not defined key set "key=%%C"
(  
endlocal
set "key=^%key:~-1%" !
)
exit /b 0

:censor
set "tmp_var=%~1"
set "%~2="
set "censored_part="
call :strlen tmp_var
set /a tmplen=len - 1
for /l %%A in (1 1 !tmplen!) do set "censored_part=!censored_part!*"
set "%~2=!tmp_var:~0,1!!censored_part!!tmp_var:~%tmplen%,1!"
exit /b 0

:softclear
if "%~1"=="xtr" (
	for /l %%A in (1,1,33) do <nul set/p=!ESC![%%A;23H│                                                                                                        
) else for /l %%A in (1,1,33) do <nul set/p=!ESC![%%A;23H│                                                                          
exit /b

:pressr
	set disp_bundle=champ
	set disp=icons
	<nul set /p=!ESC![?25l
	set gift_start=1
	set champ_start=1
	set purchase_start=1
	set startsel=1
	set skin_start=1
	set icons_start=1
	set friend_start=1
	set rare_start=1
	set giftl=0
	set friendl=0
	set purchasel=0
	set tft_map_start=1
	set tft_booms_start=1
	set tft_little_legend_start=1
	set tmp1=!champsamount[%sel%]!
	set tmp2=!skinsamount[%sel%]!
	set tmp3=!tft_little_legend_count[%sel%]!
	if "!icons[%sel%]!"=="" set "icons[%sel%]=0"
	if !icons[%sel%]! lss !max_y! (
		set "icons_end=!icons[%sel%]!"
        ) else set icons_end=!max_y!

	if !skinsamount[%sel%]! lss !max_y! (
		set "skin_end=!skinsamount[%sel%]!"
	) else set skin_end=!max_y!
	if !champsamount[%sel%]! lss !max_y! (
		set "champ_end=!champsamount[%sel%]!"
	) else set "champ_end=!max_y!"

	if !tft_map_skin_count[%sel%]! lss !max_y! (
		set "tft_map_end=!tft_map_skin_count[%sel%]!"
	) else set "tft_map_end=!max_y!"
	if !tft_booms_count[%sel%]! lss !max_y! (
		set "tft_booms_end=!tft_booms_count[%sel%]!"
	) else set "tft_booms_end=!max_y!"
	if !tft_little_legend_count[%sel%]! lss !max_y! (
		set "tft_little_legend_end=!tft_little_legend_count[%sel%]!"
	) else set "tft_little_legend_end=!max_y!"

	if !rare[%sel%]! lss !max_y! (
		set "rare_end=!rare[%sel%]!"
	) else set "rare_end=!max_y!"
	echo=!ESC![2J!ESC![1;1H
	for /l %%A in (1,1,33) do <nul set/p=!ESC![%%A;23H│
	goto :view_acc
)
goto :choice_repeat

:view_acc
if "!censormode!"=="[X]" (
	title !region[%sel%]! - Censored
) else (
	title !region[%sel%]! - !summoner[%sel%]!
)
echo=!ESC![1;1H!sel_clr! Imported information !esc![0m
echo=!ESC![2;1H──────────────────────┤
echo=!ESC![4;3HAccount info
echo=!ESC![7;3HRanks
echo=!ESC![10;3HChampions ^(!champsamount[%sel%]!^)
echo=!ESC![13;3HSkins ^(!skinsamount[%sel%]!^)
echo=!ESC![16;3HIcons ^(!icons[%sel%]!^)
echo=!ESC![19;3HInventory
echo=!ESC![22;3HTFT Map Skins ^(!tft_map_skin_count[%sel%]!^)
echo=!ESC![25;3HTFT Booms ^(!tft_booms_count[%sel%]!^)
echo=!ESC![28;3HLittle Legends ^(!tft_little_legend_count[%sel%]!^)
echo=!ESC![31;3HURS ^(!rare[%sel%]!^)
if !startsel!==1 (
	if "!last_match[%sel%]!"==" " set "last_match[%sel%]=Over 2 years ago"
	echo=!ESC![4;3H!!sel_norm_clr!Account info!esc![0m
	echo=!ESC![4;3H!ESC![!spacescount!GRegion                 !region[%sel%]!
	echo=!ESC![!spacescount!GOriginal region        !censor_clr!!original_creation_region[%sel%]!!esc![0m
	echo=!ESC![!spacescount!GSummoner Name          !censor_clr!!summoner[%sel%]!!esc![0m
	echo=!ESC![!spacescount!GUsername               !censor_clr!!login[%sel%]!!esc![0m
	echo=!ESC![!spacescount!GPassword               !censor_clr!!password[%sel%]!!esc![0m
	echo=!ESC![!spacescount!GLevel                  !level[%sel%]!
	echo=!ESC![!spacescount!GEmail verified         !emailverified[%sel%]!
	echo=!ESC![!spacescount!GAccount email          !censor_clr!!email[%sel%]!!esc![0m
	echo=!ESC![!spacescount!GCreation date          !creation_date[%sel%]!
	echo=!ESC![!spacescount!GLast password change   !password_change_date[%sel%]!
	echo=!ESC![!spacescount!GHonor level            !honorlevel[%sel%]!
	echo=!ESC![!spacescount!GHonor checkpoint       !checkpoint[%sel%]!
	echo=!ESC![!spacescount!GXP boost end date      !xp_boost[%sel%]!
	echo=!ESC![!spacescount!GRanked restriction     !rankedrestriction[%sel%]!
	echo=!ESC![!spacescount!GPrime capsule count    !prime_capsules[%sel%]!
	echo=!ESC![!spacescount!GLast match played      !last_match[%sel%]!
	echo=!ESC![!spacescount!GCreation country       !censor_clr!!parsed_country[%sel%]! ^(!creation_country[%sel%]!^)!esc![0m
	echo=!ESC![!spacescount!GVerified phone num.    !verified_number[%sel%]!
	echo=!ESC![!spacescount!GAge                    !censor_clr!!age[%sel%]! ^(!birth_year[%sel%]!^)!esc![0m
	echo=!ESC![!spacescount!GSecurity auth          !security[%sel%]!
	echo=!ESC![!spacescount!GAccount ID             !censor_clr!!accountid[%sel%]!!esc![0m
	echo=!ESC![!spacescount!GSummoner ID            !censor_clr!!summonerid[%sel%]!!esc![0m
	echo=!ESC![!spacescount!GPuuid                  !censor_clr!!puuid[%sel%]!!esc![0m
	echo=!ESC![!spacescount!GExported at            !export_date[%sel%]!
	set pw=
) else if !startsel!==2 (
	echo=!ESC![7;3H!sel_norm_clr!Ranks!esc![0m!ESC![3;3H
	echo=!ESC![!spacescount!G!sel_norm_clr!Ranked Solo/Duo!esc![0m
	echo=!ESC![!spacescount!GRank:            !RANKED_SOLO_5X5[rank][%sel%]! !RANKED_SOLO_5X5[division][%sel%]! !RANKED_SOLO_5X5[lp][%sel%]!LP
	echo=!ESC![!spacescount!GWin/Loss:        !RANKED_SOLO_5X5[wins][%sel%]!:!RANKED_SOLO_5X5[losses][%sel%]!
	echo=!ESC![!spacescount!GWinrate:         !RANKED_SOLO_5X5[winRate][%sel%]!
	echo=!ESC![!spacescount!GPlacement games: !RANKED_SOLO_5X5[placementGamesRemaining][%sel%]!
	if defined RANKED_SOLO_5X5[daysUntilDecay][%sel%] echo=!ESC![!spacescount!GDecay:           !RANKED_SOLO_5X5[daysUntilDecay][%sel%]!d ^(!RANKED_SOLO_5X5[decayDate][%sel%]!^)
	echo=!ESC![!spacescount!G
	echo=!ESC![!spacescount!G!sel_norm_clr!Ranked Flex!esc![0m
	echo=!ESC![!spacescount!GRank:            !RANKED_FLEX_SR[rank][%sel%]! !RANKED_FLEX_SR[division][%sel%]! !RANKED_FLEX_SR[lp][%sel%]!LP
	echo=!ESC![!spacescount!GWin/Loss:        !RANKED_FLEX_SR[wins][%sel%]!:!RANKED_FLEX_SR[losses][%sel%]!
	echo=!ESC![!spacescount!GWinrate:         !RANKED_FLEX_SR[winRate][%sel%]!
	echo=!ESC![!spacescount!GPlacement games: !RANKED_FLEX_SR[placementGamesRemaining][%sel%]!
	if defined RANKED_FLEX_SR[daysUntilDecay][%sel%] echo=!ESC![!spacescount!GDecay:           !RANKED_FLEX_SR[daysUntilDecay][%sel%]!d ^(!RANKED_FLEX_SR[decayDate][%sel%]!^)
	echo=!ESC![!spacescount!G
	echo=!ESC![!spacescount!G!sel_norm_clr!Ranked TFT!esc![0m
	echo=!ESC![!spacescount!GRank:            !RANKED_TFT[rank][%sel%]! !RANKED_TFT[division][%sel%]! !RANKED_TFT[lp][%sel%]!LP
	echo=!ESC![!spacescount!GWin/Loss:        !RANKED_TFT[wins][%sel%]!:!RANKED_TFT[losses][%sel%]!
	echo=!ESC![!spacescount!GWinrate:         !RANKED_TFT[winRate][%sel%]!
	echo=!ESC![!spacescount!GPlacement games: !RANKED_TFT[placementGamesRemaining][%sel%]!
	if defined RANKED_TFT[daysUntilDecay][%sel%] echo=!ESC![!spacescount!GDecay:           !RANKED_TFT[daysUntilDecay][%sel%]!d ^(!RANKED_TFT[decayDate][%sel%]!^)
	echo=!ESC![3;3H!ESC![!thrd_space!G
	echo=!ESC![!thrd_space!G!sel_norm_clr!Ranked TFT Double Up!esc![0m
	echo=!ESC![!thrd_space!GRank:            !RANKED_TFT_DOUBLE_UP[rank][%sel%]! !RANKED_TFT_DOUBLE_UP[division][%sel%]! !RANKED_TFT_DOUBLE_UP[lp][%sel%]!LP
	echo=!ESC![!thrd_space!GWin/Loss:        !RANKED_TFT_DOUBLE_UP[wins][%sel%]!:!RANKED_TFT_DOUBLE_UP[losses][%sel%]!
	echo=!ESC![!thrd_space!GWinrate:         !RANKED_TFT_DOUBLE_UP[winRate][%sel%]!
	echo=!ESC![!thrd_space!GPlacement games: !RANKED_TFT_DOUBLE_UP[placementGamesRemaining][%sel%]!
	if defined RANKED_TFT_DOUBLE_UP[daysUntilDecay][%sel%] echo=!ESC![!thrd_space!GDecay:           !RANKED_TFT_DOUBLE_UP[daysUntilDecay][%sel%]!d ^(!RANKED_TFT_DOUBLE_UP[decayDate][%sel%]!^)
	echo=!ESC![!thrd_space!G
	echo=!ESC![!thrd_space!G!sel_norm_clr!Ranked TFT Turbo!esc![0m
	echo=!ESC![!thrd_space!GRank:            !RANKED_TFT_TURBO[rank][%sel%]! !RANKED_TFT_TURBO[division][%sel%]! !RANKED_TFT_TURBO[lp][%sel%]!LP
	echo=!ESC![!thrd_space!GWin/Loss:        !RANKED_TFT_TURBO[wins][%sel%]!:!RANKED_TFT_TURBO[losses][%sel%]!
	echo=!ESC![!thrd_space!GWinrate:         !RANKED_TFT_TURBO[winRate][%sel%]!
	echo=!ESC![!thrd_space!GPlacement games: !RANKED_TFT_TURBO[placementGamesRemaining][%sel%]!
	if defined RANKED_TFT_TURBO[daysUntilDecay][%sel%] echo=!ESC![!thrd_space!GDecay:           !RANKED_TFT_TURBO[daysUntilDecay][%sel%]!d ^(!RANKED_TFT_TURBO[decayDate][%sel%]!^)
) else if !startsel!==3 (
	for /f %%s in ("!sel!") do (
	echo=!ESC![10;3H!sel_norm_clr!Champions ^(!champsamount[%sel%]!^)!esc![0m!ESC![3;5H
	if "!disp_bundle!"=="champ" (
		echo=!sel_norm_clr!!ESC![!lowerspacescount!G # !ESC![!spacescount!GName!ESC![!thrd_space!GObtain date!ESC![0m
		echo=
		for /l %%A in (!champ_start! 1 !champ_end!) do (
			echo=!ESC![!lowerspacescount!G %%A !ESC![!spacescount!G!champ_name[%%A][%%s]!                   !ESC![!thrd_space!G!champ_date[%%A][%%s]!                                   
		)
		echo=
		echo=
		echo=
		echo=!ESC![!lowerspacescount!G !sel_norm_clr!TIP!ESC![0m: Press !ESC![38;5;241m{ X }!ESC![0m to extract purchased bundles
	) else (
		echo=!ESC![!lowerspacescount!G!sel_norm_clr! =====!ESC![0m Known purchased bundles !sel_norm_clr!=====!ESC![0m
		echo=
		call :detect_bundle
		echo=
		echo=
		echo=
		echo=!ESC![!lowerspacescount!G !sel_norm_clr!TIP!ESC![0m: Press !ESC![38;5;241m{ X }!ESC![0m to go back and view champions
	)
)
) else if !startsel!==4 (
	for /f %%s in ("!sel!") do (
	echo=!ESC![13;3H!sel_norm_clr!Skins ^(!skinsamount[%sel%]!^)!esc![0m!ESC![3;5H	
	echo=!sel_norm_clr!!ESC![!lowerspacescount!G # !ESC![!spacescount!GName!ESC![!thrd_space!GObtain date!ESC![!fourth_space!GLegacy!ESC![!fifth_space!GRarity!ESC![0m
	echo=
	for /l %%A in (!skin_start! 1 !skin_end!) do (
		echo=!ESC![!lowerspacescount!G %%A !ESC![!spacescount!G!skin_name[%%A][%%s]!                   !ESC![!thrd_space!G!skin_date[%%A][%%s]!!ESC![!fourth_space!G!skin_islegacy[%%A][%%s]!              !ESC![!fifth_space!G!skin_rarity[%%A][%%s]:~1!       
	)
)
) else if !startsel!==5 (
	for /f %%s in ("!sel!") do (
	echo=!ESC![16;3H!sel_norm_clr!Icons ^(!icons[%sel%]!^)!esc![0m!ESC![3;5H	
	if "!disp!"=="icons" (
		echo=!sel_norm_clr!!ESC![!lowerspacescount!G # !ESC![!spacescount!GName!ESC![!fourth_space!GObtain date!ESC![0m
		echo=
		for /l %%A in (!icons_start! 1 !icons_end!) do (
			echo=!ESC![!lowerspacescount!G %%A !ESC![!spacescount!G!icon_name[%%A][%%s]!!esc![0m                                        !ESC![!fourth_space!G!icon_date[%%A][%%s]:~0,20!   	    	
		)
		echo=
		echo=
		echo=
		echo=!ESC![!lowerspacescount!G !sel_norm_clr!TIP!ESC![0m: Press !ESC![38;5;241m{ X }!ESC![0m to extract important icons
	) else (
	for /l %%A in (1 1 !icons_end!) do (
		for /l %%B in (1 1 !gi!) do (
			if "!gift_icon_name[%%B]!"=="!icon_name[%%A][%%s]!" (
				echo=!ESC![!lowerspacescount!G !gift_icon_desc[%%B]! !ESC![38;5;241m^(!icon_name[%%A][%%s]!^)!ESC![0m
				set fnd=true
			)
		)
	)
	if not !fnd!==true echo=!ESC![!lowerspacescount!G No important icons found. :^(
	set "fnd="
	echo=
	echo=!ESC![!lowerspacescount!G !sel_norm_clr!TIP!ESC![0m: Press !ESC![38;5;241m{ X }!ESC![0m to go back to icon list

	)
)
) else if !startsel!==6 (
	for /f %%s in ("!sel!") do (
	set /a "rp_value=(!rarity_count[%sel%][kUltimate]!*3250)+(!rarity_count[%sel%][kLegendary]!*1820)+(!rarity_count[%sel%][kEpic]!*1350)+(!rarity_count[%sel%][kNoRarity]!*750)"

	echo=!ESC![19;3H!sel_norm_clr!Inventory!esc![0m!ESC![2;5H	
	echo=!ESC![!spacescount!G
	echo=!ESC![!spacescount!G!ESC![38;2;253;144;4mUltimate skins!ESC![0m         !rarity_count[%sel%][kUltimate]!
	echo=!ESC![!spacescount!G!ESC![38;2;217;3;222mMythic skins!ESC![0m           !rarity_count[%sel%][kMythic]!
	echo=!ESC![!spacescount!G!ESC![38;2;255;7;4mLegendary skins!ESC![0m        !rarity_count[%sel%][kLegendary]!
	echo=!ESC![!spacescount!G!ESC![38;2;0;220;250mEpic skins!ESC![0m             !rarity_count[%sel%][kEpic]!
	echo=!ESC![!spacescount!GNo rarity skins        !rarity_count[%sel%][kNoRarity]!
	echo=!ESC![!spacescount!G!ESC![38;2;197;164;101mLegacy skins!ESC![0m           !legacy_count[%sel%][True]!
	echo=!ESC![!spacescount!GNon-legacy skins       !legacy_count[%sel%][False]!
	echo=!ESC![!spacescount!GRiot Points            !rp[%sel%]!
	echo=!ESC![!spacescount!GBlue Essence           !be[%sel%]!
	echo=!ESC![!spacescount!GMythic Essence         !me[%sel%]!
	echo=!ESC![!spacescount!GOrange Essence         !oe[%sel%]!
	echo=!ESC![!spacescount!GSkin amount            !skinsamount[%sel%]!
	echo=!ESC![!spacescount!GRare skin amount       !rare[%sel%]!
	echo=!ESC![!spacescount!GChampion amount        !champsamount[%sel%]!
	echo=!ESC![!spacescount!GWard skin count        !ward_count[%sel%]!
	echo=!ESC![!spacescount!GIcon count             !icon_count[%sel%]!
	echo=!ESC![!spacescount!GEmote count            !emote_count[%sel%]!
	echo=!ESC![!spacescount!GRune page count        !rune_page_count[%sel%]!
	echo=!ESC![!spacescount!GRune page date         !rune_page_date[%sel%]!
	echo=!ESC![!spacescount!GTFT Map Skins          !tft_map_skin_count[%sel%]!
	echo=!ESC![!spacescount!GTFT Booms              !tft_booms_count[%sel%]!
	echo=!ESC![!spacescount!GTFT Little Legends     !tft_little_legend_count[%sel%]!
	echo=!ESC![!spacescount!GLast obtained champion !champ_date[%tmp1%][%sel%]!
	echo=!ESC![!spacescount!GLast obtained skin     !skin_date[%tmp2%][%sel%]!
	echo=!ESC![!spacescount!GLast obtained TFT LL   !!tft_little_legend_date[%tmp3%][%sel%]!
	echo=!ESC![!spacescount!GEstimated RP value     !rp_value! RP !ESC![38;5;241m^(only in skins^)!ESC![0m




)
) else if !startsel!==7 (
	for /f %%s in ("!sel!") do (
	echo=!ESC![22;3H!sel_norm_clr!TFT Map Skins ^(!tft_map_skin_count[%sel%]!^)!esc![0m
	echo=!ESC![4;5H!sel_norm_clr!!ESC![!lowerspacescount!G #!ESC![!spacescount!GName!ESC![!thrd_space!GObtain date!ESC![0m!ESC![5;5H
	for /l %%A in (!tft_map_start! 1 !tft_map_end!) do (
		echo=!ESC![!lowerspacescount!G %%A !ESC![!spacescount!G!tft_map_skin_name[%%A][%%s]!                        !ESC![!thrd_space!G!tft_map_skin_date[%%A][%%s]!                                    
	)
)
) else if !startsel!==8 (
	for /f %%s in ("!sel!") do (
	echo=!ESC![25;3H!sel_norm_clr!TFT Booms ^(!tft_booms_count[%sel%]!^)!esc![0m
	echo=!ESC![4;5H!sel_norm_clr!!ESC![!lowerspacescount!G #!ESC![!spacescount!GName!ESC![!thrd_space!GObtain date!ESC![0m!ESC![5;5H
	for /l %%A in (!tft_booms_start! 1 !tft_booms_end!) do (
		echo=!ESC![!lowerspacescount!G %%A !ESC![!spacescount!G!tft_booms_name[%%A][%%s]!                          !ESC![!thrd_space!G!tft_booms_date[%%A][%%s]!                                    
	)
)
) else if !startsel!==9 (
	for /f %%s in ("!sel!") do (
	echo=!ESC![28;3H!sel_norm_clr!Little Legends ^(!tft_little_legend_count[%sel%]!^)!esc![0m
	echo=!ESC![4;5H!sel_norm_clr!!ESC![!lowerspacescount!G #!ESC![!spacescount!GName!ESC![!thrd_space!GObtain date!ESC![0m!ESC![5;5H
	for /l %%A in (!tft_little_legend_start! 1 !tft_little_legend_end!) do (
		echo=!ESC![!lowerspacescount!G %%A !ESC![!spacescount!G!tft_little_legend_name[%%A][%%s]!                             !ESC![!thrd_space!G!tft_little_legend_date[%%A][%%s]!                                    
	)
)
) else if !startsel!==0 (
	for /f %%s in ("!sel!") do (
	echo=!ESC![31;3H!sel_norm_clr!URS ^(!rare[%sel%]!^)!esc![0m!ESC![3;5H	
	echo=!sel_norm_clr!!ESC![!lowerspacescount!G # !ESC![!spacescount!GOwned rare skin name!ESC![0m
	echo=
	for /l %%A in (!rare_start! 1 !rare_end!) do (
		echo=!ESC![!lowerspacescount!G %%A !ESC![!spacescount!G!!rare_skin[%%s][%%A]!
	)
))
:: lower space coumt

rem id type obtaindate to from
)
call :xcopy
if /i "!key!"=="e" (
	exit
)
for /l %%A in (0 1 9) do (
	if /i "!key!"=="%%A" (
		set "startsel=%%A"
		for /l %%A in (1,1,33) do <nul set/p=!ESC![%%A;23H│                                                                                                                    
		
	)
)
if /i "!startsel!"=="4" (
	if /i "!key!"=="s" (
		if not !skin_end! equ !skinsamount[%sel%]! (
			set /a skin_start+=1
			set /a skin_end+=1
		)
	)
	if /i "!key!"=="w" (
		if not !skin_start! equ 1 (
			set /a skin_start-=1
			set /a skin_end-=1
		)
	)
)
if /i "!startsel!"=="3" (
	if /i "!key!"=="s" (
		if not !champ_end! equ !champsamount[%sel%]! (
			set /a champ_start+=1
			set /a champ_end+=1
		)
	)
	if /i "!key!"=="w" (
		if not !champ_start! equ 1 (
			set /a champ_start-=1
			set /a champ_end-=1
		)
	)
	if /i "!key!"=="x" (
		if "!disp_bundle!"=="champ" (
			call :softclear xtr
			set "disp_bundle=bundle"
		) else (
			call :softclear xtr
			set "disp_bundle=champ"
		)	
	)
)
if /i "!startsel!"=="5" (
	if /i "!key!"=="s" (
		if not !icons_end! equ !icons[%sel%]! (
			set /a icons_start+=1
			set /a icons_end+=1
		)
	)
	if /i "!key!"=="w" (
		if not !icons_start! equ 1 (
			set /a icons_start-=1
			set /a icons_end-=1
		)
	)

	if /i "!key!"=="x" (
		if "!disp!"=="icons" (
			call :softclear xtr
			set "disp=gifts"
		) else (
			call :softclear xtr
			set "disp=icons
		)
	)

)
if /i "!startsel!"=="7" (
	if /i "!key!"=="s" (
		if not !tft_map_end! equ !tft_map_skin_count[%sel%]! (
			set /a tft_map_start=1
			set /a tft_map_end+=1
		)
	)
	if /i "!key!"=="w" (
		if not !tft_map_start! equ 1 (
			set /a tft_map_start-=1
			set /a tft_map_end-=1
		)
	)
)
if /i "!startsel!"=="8" (
	if /i "!key!"=="s" (
		if not !tft_booms_end! equ !tft_booms_count[%sel%]! (
			set /a tft_booms_start+=1
			set /a tft_booms_end+=1
		)
	)
	if /i "!key!"=="w" (
		if not !tft_booms_start! equ 1 (
			set /a tft_booms_start-=1
			set /a tft_booms_end-=1
		)
	)
)
if /i "!startsel!"=="9" (
	if /i "!key!"=="s" (
		if not !tft_little_legend_end! equ !tft_little_legend_count[%sel%]! (
			set /a tft_little_legend_start+=1
			set /a tft_little_legend_end+=1
		)
	)
	if /i "!key!"=="w" (
		if not !tft_little_legend_start! equ 1 (
			set /a tft_little_legend_start-=1
			set /a tft_little_legend_end-=1
		)
	)
)


if /i "!startsel!"=="0" (
	if /i "!key!"=="s" (
		if not !rare_end! equ !rare[%sel%]! (
			set /a rare_start+=1
			set /a rare_end+=1
		)
	)
	if /i "!key!"=="w" (
		if not !rare_start! equ 1 (
			set /a rare_start-=1
			set /a rare_end-=1
		)
	)
)
goto :view_acc


:detect_bundle
call :load_champ_and_skins "!sel!"
set "tmp_var=!skinsamount[%sel%]!"
for %%. in ("!sel!") do for /l %%A in (1 1 !tmp_var!) do (
	set "skin_list_to_copy=!skin_list_to_copy!, !skin_name[%%A][%%~.]!"
)
set "skin_list_to_copy=!skin_list_to_copy:~1,9999!"
set "skin_list_to_copy=!skin_list_to_copy:&=^&!"
set "champion_list_to_copy="
call :load_champ_and_skins "!sel!"
set "tmp_var=!champsamount[%sel%]!"
for %%. in ("!sel!") do for /l %%A in (1 1 !tmp_var!) do (
	set "champion_list_to_copy=!champion_list_to_copy!, !champ_name[%%A][%%~.]!"
)
set "champion_list_to_copy=!champion_list_to_copy:~2,9999!"
set "champion_list_to_copy=!champion_list_to_copy:&=^&!"
rem digital collector pack 
for %%s in ("!sel!") do for /l %%A in (1 1 !champsamount[%sel%]!) do (
	if /i "!champ_name[%%A][%%~s]!"=="kayle" set "save[1]=%%A"
	if /i "!champ_name[%%A][%%~s]!"=="fiddlesticks" set "save[2]=%%A"
	if /i "!champ_name[%%A][%%~s]!"=="corki" set "champs_save[1]=%%A"
	if /i "!champ_name[%%A][%%~s]!"=="karthus" set "champs_save[2]=%%A"
)
if not "!champ_date[%save[1]%][%sel%]!"=="" (
	if "!champ_date[%save[1]%][%sel%]!"=="!champ_date[%save[2]%][%sel%]!" (
		if "!skin_list_to_copy:Goth Annie=!"=="!skin_list_to_copy!" (
			echo=!ESC![!lowerspacescount!G Retail Collector's Pack detected !ESC![38;5;241m^(!champ_date[%save[1]%][%sel%]!^)!ESC![0m
		) else (
			echo=!ESC![!lowerspacescount!G Digital Collector's Pack detected !ESC![38;5;241m^(!champ_date[%save[1]%][%sel%]!^)!ESC![0m
)
		)
	)
)
if not "!champ_date[%champs_save[1]%][%sel%]!"=="" (
	if "!champ_date[%champs_save[1]%][%sel%]!"=="!champ_date[%champs_save[2]%][%sel%]!" (
		echo=!ESC![!lowerspacescount!G Champions Bundle detected !ESC![38;5;241m^(!champ_date[%champs_save[1]%][%sel%]!^)!ESC![0m
	)
)
if not "!skin_list_to_copy:Black Alistar=!"=="!skin_list_to_copy!" (
	echo=!ESC![!lowerspacescount!G Pre-order of Digital Collector's Pack detected !ESC![38;5;241m^(Also first non-skin purchase^)!ESC![0m
)
if not "!skin_list_to_copy:Silver Kayle=!"=="!skin_list_to_copy!" (
	echo=!ESC![!lowerspacescount!G Retail Collector's Pack detected !ESC![38;5;241m^(Silver Kayle^)!ESC![0m
)
if not "!skin_list_to_copy:Young Ryze=!"=="!skin_list_to_copy!" (
	echo=!ESC![!lowerspacescount!G Pre-order of Retail Collector's Pack detected !ESC![38;5;241m^(Also first non-skin purchase^)!ESC![0m
)
for %%s in ("!sel!") do for /l %%A in (1 1 !skinsamount[%%~s]!) do (
	if /i "!skin_name[%%A][%%~s]!"=="high noon yasuo" set "mid_save[1]=%%A"
	if /i "!skin_name[%%A][%%~s]!"=="frostfire annie" set "mid_save[2]=%%A"
	if /i "!skin_name[%%A][%%~s]!"=="frosted ezreal" set "adc_save[1]=%%A"
	if /i "!skin_name[%%A][%%~s]!"=="dragonslayer vayne" set "adc_save[2]=%%A"
	if /i "!skin_name[%%A][%%~s]!"=="crime city graves" set "jg_save[1]=%%A"
	if /i "!skin_name[%%A][%%~s]!"=="neon strike vi" set "jg_save[2]=%%A"
	if /i "!skin_name[%%A][%%~s]!"=="koi nami" set "supp_save[1]=%%A"
	if /i "!skin_name[%%A][%%~s]!"=="blade mistress morgana" set "supp_save[2]=%%A"
	if /i "!skin_name[%%A][%%~s]!"=="panda teemo" set "top_save[1]=%%A"
	if /i "!skin_name[%%A][%%~s]!"=="battle bunny riven" set "top_save[2]=%%A"
)
if defined mid_save[1] if "!skin_date[%mid_save[1]%][%sel%]!"=="!skin_date[%mid_save[2]%][%sel%]!" echo=!ESC![!lowerspacescount!G Mid Lane Starter Pack detected !ESC![38;5;241m^(!skin_date[%mid_save[1]%][%sel%]!^)!ESC![0m
if defined adc_save[1] if "!skin_date[%adc_save[1]%][%sel%]!"=="!skin_date[%adc_save[2]%][%sel%]!" echo=!ESC![!lowerspacescount!G Bot Lane Starter Pack detected !ESC![38;5;241m^(!skin_date[%adc_save[1]%][%sel%]!^)!ESC![0m
if defined supp_save[1] if "!skin_date[%supp_save[1]%][%sel%]!"=="!skin_date[%supp_save[2]%][%sel%]!" echo=!ESC![!lowerspacescount!G Support Starter Pack detected !ESC![38;5;241m^(!skin_date[%supp_save[1]%][%sel%]!^)!ESC![0m
if defined top_save[1] if "!skin_date[%top_save[1]%][%sel%]!"=="!skin_date[%top_save[2]%][%sel%]!" echo=!ESC![!lowerspacescount!G Top Lane Starter Pack detected !ESC![38;5;241m^(!skin_date[%top_save[1]%][%sel%]!^)!ESC![0m
if defined jg_save[1] if "!skin_date[%jg_save[1]%][%sel%]!"=="!skin_date[%jg_save[2]%][%sel%]!" echo=!ESC![!lowerspacescount!G Jungle Starter Pack detected !ESC![38;5;241m^(!skin_date[%jg_save[1]%][%sel%]!^)!ESC![0m
exit /b 0

:value_convert <> <sel> <formatname>
set "ifp="
if "%~3"=="csv" set "ifp="
if "%~3"=="txt" set "ifp='"
set "!ifp!owned rare skins="
set "!ifp!owned champions="
set "!ifp!owned skins="
set "!ifp!owned tft booms="
set "!ifp!owned tft little legends="
set "!ifp!owned tft map skins="
set "!ifp!owned icons="
set "!ifp!friendlist="
chcp 437>nul
if not "!skinsamount[%~2]!"=="0" (
	set "!ifp!first 3 skins="!skin_name[1][%~2]! - !skin_date[1][%~2]!, !skin_name[2][%~2]! - !skin_date[2][%~2]!, !skin_name[3][%~2]! - !skin_date[3][%~2]!""
)
if not "!champsamount[%~2]!"=="0" (
	set "!ifp!first 5 champions="!champ_name[1][%~2]! - !champ_date[1][%~2]!, !champ_name[2][%~2]! - !champ_date[2][%~2]!, !champ_name[3][%~2]! - !champ_date[3][%~2]!, !champ_name[4][%~2]! - !champ_date[4][%~2]!, !champ_name[5][%~2]! - !champ_date[5][%~2]!""
)
set "!ifp!password=!password[%~2]!"
chcp 65001>nul
set "!ifp!account id[%~2]=!accountid[%~2]!"
set "!ifp!Summoner ID[%~2]=!summonerid[%~2]!"
set "!ifp!puuid[%~2]=!puuid[%~2]!"

set "!ifp!friends count=!friendscount[%~2]!"
set "!ifp!icon count=!icons[%~2]!"
if not "!friends count!"=="0" (
	for %%. in ("%~2") do for /l %%A in (1 1 !friendscount[%~2]!) do (
		set "!ifp!friendlist=!friendlist!, !friend_name[%%A][%%~.]!"
	)
	set "!ifp!friendlist=!friendlist:~2,9999!"
) else set "!ifp!friendlist=None"

if defined rare_skin[%~2][1] (
	for /l %%A in (1 1 !rare[%~2]!) do (
		set "!ifp!owned rare skins=!owned rare skins!, !rare_skin[%~2][%%A]!"
	)
	set "!ifp!owned rare skins=!owned rare skins:~2,9999!"
	set "!ifp!owned rare skins="!owned rare skins!""
) else set "!ifp!owned rare skins=None"
for %%. in ("%~2") do for /l %%A in (1 1 !champsamount[%~2]!) do (
	set "!ifp!owned champions=!owned champions!, !champ_name[%%A][%%~.]!"
)
set "!ifp!owned champions=!owned champions:~2,9999!"
set "!ifp!owned champions="!owned champions!""

if not "!skinsamount[%~2]!"=="0" (
	for %%. in ("%~2") do for /l %%A in (1 1 !skinsamount[%~2]!) do (
		set "!ifp!owned skins=!owned skins!, !skin_name[%%A][%%~.]!"
	)
	set "!ifp!owned skins=!owned skins:~2,9999!"
	set "!ifp!owned skins="!owned skins!""
) else set "!ifp!owned skins=None"

for %%. in ("%~2") do for /l %%A in (1 1 !tft_map_skin_count[%~2]!) do (
	set "!ifp!owned tft map skins=!owned tft map skins!, !tft_map_skin_name[%%A][%~2]!"
)
set "!ifp!owned tft map skins=!owned tft map skins:~2,9999!"
set "!ifp!owned tft map skins=!owned tft map skins:&=^&!"
set "!ifp!owned tft map skins="!owned tft map skins!""

if not "!icon count!"=="0" (
	for %%. in ("%~2") do for /l %%A in (1 1 !icons[%~2]!) do (
		set "!ifp!owned icons=!owned icons!, !icons_name[%%A][%~2]!"
	)
	set "!ifp!owned icons=!owned icons:~2,9999!"
	set "!ifp!owned icons="!owned icons!""
) else set "!ifp!owned icons=None"

if not "!tft booms count!"=="0" (
	for %%. in ("%~2") do for /l %%A in (1 1 !tft_booms_count[%~2]!) do (
		set "!ifp!owned tft booms=!owned tft booms!, !tft_booms_name[%%A][%~2]!"
	)
	set "!ifp!owned tft booms=!owned tft booms:~2,9999!"
	set "!ifp!owned tft booms="!owned tft booms!""
) else set "!ifp!owned tft booms=None"

for %%. in ("%~2") do for /l %%A in (1 1 !tft_little_legend_count[%~2]!) do (
	set "!ifp!owned tft little legends=!owned tft little legends!, !tft_little_legend_name[%%A][%~2]!"
)
set "!ifp!owned tft little legends=!owned tft little legends:~2,9999!"
set "!ifp!owned tft little legends="!owned tft little legends!""
set "!ifp!region=!region[%~2]!"
set "!ifp!username=!login[%~2]!"
set "!ifp!summoner name=!summoner[%~2]!"
set "!ifp!email is verified?=!emailverified[%~2]!"
set "!ifp!level=!level[%~2]!"
set "!ifp!RP=!rp[%~2]!"
set "!ifp!BE=!be[%~2]!"
set "!ifp!ME=!me[%~2]!"
set "!ifp!OE=!oe[%~2]!"
set "!ifp!champions count=!champsamount[%~2]!"
set "!ifp!skins count=!skinsamount[%~2]!"
set "!ifp!no rarity skin count=!rarity_count[%~2][kNoRarity]!"
set "!ifp!ultimate skin count=!rarity_count[%~2][kUltimate]!"
set "!ifp!mythic skin count=!rarity_count[%~2][kMythic]!"
set "!ifp!legendary skin count=!rarity_count[%~2][kLegendary]!"
set "!ifp!epic skin count=!rarity_count[%~2][kEpic]!"
set "!ifp!legacy skin count=!legacy_count[%~2[True]!"
set "!ifp!non-legacy skin count=!legacy_count[%~2][False]!"

(
set "!ifp!soloq rank=!ranked_solo_5x5[rank][%~2]! !ranked_solo_5x5[division][%~2]! !ranked_solo_5x5[lp][%~2]!LP"
set "!ifp!flexq rank=!RANKED_FLEX_SR[rank][%~2]! !RANKED_FLEX_SR[division][%~2]! !RANKED_FLEX_SR[lp][%~2]!LP"
set "!ifp!tft rank=!RANKED_TFT[rank][%~2]! !RANKED_TFT[division][%~2]! !RANKED_TFT[lp][%~2]!LP"
set "!ifp!tft double up rank=!RANKED_TFT_DOUBLE_UP[rank][%~2]! !RANKED_TFT_DOUBLE_UP[division][%~2]! !RANKED_TFT_DOUBLE_UP[lp][%~2]!LP"
set "!ifp!tft turbo rank=!RANKED_TFT_TURBO[rank][%~2]! !RANKED_TFT_TURBO[division][%~2]! !RANKED_TFT_TURBO[lp][%~2]!LP"
)2>nul >nul
set "!ifp!rare skin count=!rare[%~2]!"
set "!ifp!ward skin count=!ward_count[%~2]!"
set "!ifp!emote count=!emote_count[%~2]!"
set "!ifp!icon count=!icon_count[%~2]!"
set "!ifp!honor level=!honorlevel[%~2]!"
set "!ifp!honor checkpoint=!checkpoint[%~2]!"
set "!ifp!email address=!email[%~2]!"
set "!ifp!xp boost end=!xp_boost[%~2]!"
set "!ifp!ranked restriction remaining games=!rankedrestriction[%~2]!"
set "!ifp!rune pages count=!rune_page_count[%~2]!"
set "!ifp!prime capsules count=!prime_capsules[%~2]!"
set "!ifp!last match played=!last_match[%~2]!"
set "!ifp!verified phone number?=!verified_number[%~2]!"
set "!ifp!age=!age[%~2]!"
set "!ifp!tft map skins count=!tft_map_skin_count[%~2]!"
set "!ifp!tft booms count=!tft_booms_count[%~2]!"
set "!ifp!tft little legends count=!tft_little_legend_count[%~2]!"
set "!ifp!creation country=!parsed_country[%~2]!"
set "!ifp!export date=!export_date[%~2]!"
set "!ifp!authentication=!security[%~2]!"
set "!ifp!creation date=!creation_date[%~2]!"
set "!ifp!last password change=!password_change_date[%~2]!"
set "ifp="
exit /b 0

:txt_format
chcp 437>nul
for /f "delims=" %%A In ('powershell -command "[void][System.Reflection.Assembly]::LoadWithPartialName('System.Windows.Forms'); $SaveFileDialog = New-Object System.Windows.Forms.SaveFileDialog; $SaveFileDialog.Filter = 'Text Files (*.txt)|*.txt|All Files (*.*)|*.*'; $SaveFileDialog.ShowDialog() | Out-Null; $SaveFileDialog.FileName"') do set "save_txt=%%A"
2>nul >nul del /f /q "tmp.txt"
2>nul >nul del /f /q "result.txt"
for /f "delims=" %%A in ('powershell.exe -Command "Add-Type -AssemblyName System.Windows.Forms; $form = New-Object System.Windows.Forms.Form; $form.Text = 'Enter format'; $form.Size = New-Object System.Drawing.Size(600, 400); $label = New-Object System.Windows.Forms.Label; $label.Text = 'Please enter the desired format with values being in format {name}, example: Username: {username}'; $label.AutoSize = $true; $label.Location = New-Object System.Drawing.Point(10,10); $form.Controls.Add($label); $textbox = New-Object System.Windows.Forms.TextBox; $textbox.Multiline = $true; $textbox.Size = New-Object System.Drawing.Size(500, 300); $textbox.Location = New-Object System.Drawing.Point(20,40); $textbox.Text = '=== Riot Account Recovery Information ===' + [System.Environment]::NewLine + 'Region: {region}' + [System.Environment]::NewLine + 'Username: {username}' + [System.Environment]::NewLine + 'Password: {password}' + [System.Environment]::NewLine + 'Riot ID: {summoner name}' + [System.Environment]::NewLine + 'Email address: {email address}' + [System.Environment]::NewLine + 'Verified mail?: {Email is verified?}' + [System.Environment]::NewLine + 'Verified phone number?: {Verified phone number?}' + [System.Environment]::NewLine + 'Age [birth year]: {age}' + [System.Environment]::NewLine + 'Creation country: {creation country}' + [System.Environment]::NewLine + 'Creation date: {creation date}' + [System.Environment]::NewLine + 'Last password change: {last password change}'; $form.Controls.Add($textbox); $okButton = New-Object System.Windows.Forms.Button; $okButton.Text = 'Export'; $okButton.Location = New-Object System.Drawing.Point(200, 200); $okButton.Add_Click({$form.DialogResult = [System.Windows.Forms.DialogResult]::OK}); $form.Controls.Add($okButton); if ($form.ShowDialog() -eq [System.Windows.Forms.DialogResult]::OK) { $textbox.Text }"') do (
	echo=%%A>>tmp.txt
)
if "%~1"=="single" (
	echo Exporting !username[%sel%]!...
	call :value_convert . "!sel!" txt
	call :start_export_txt
	echo=Done. Saved to !save_txt!
	exit /b 0
)
if "%~1"=="all" (
	echo Exporting...
	for /l %%A in (1,1,!acc!) do (
		echo Exporting !username[%%A]!...
		call :value_convert . "%%A" txt
		call :start_export_txt
	)
	echo=Done. Saved to !save_txt!
	exit /b 0
)


:start_export_txt
chcp 65001>nul
set linec=0
for /f "delims=" %%C in ('type "tmp.txt"') do (
	set /a linec+=1
	set "line=%%C"
	for /f "tokens=1,2 delims=='" %%A in ('2^>nul set "'"') do (
		set "line=!line:{%%A}=%%B!"
		set "line[!linec!]=!line!"
	)
)
for /l %%A in (1 1 !linec!) do (
	echo=!line[%%A]!>>!save_txt!"
)
exit /b 0



