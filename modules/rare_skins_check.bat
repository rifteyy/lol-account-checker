@echo off
setlocal enabledelayedexpansion
cd /d "%~dp0"
cd..
set /a rslist=0
set /a rs=0
for /f "delims=" %%A in (settings\rare_skins.txt) do (
	set /a rslist+=1
	set "rare_skin[!rslist!]=%%A"
)
for /l %%B in (1 1 !rslist!) do ( for /f "delims=" %%A in (acc_%~1\account_skins.txt) do ( 
	set "line=%%A"
	for %%C in ("!rare_skin[%%B]!") do if not "!line!"=="!line:%%~C=!" (
		set /a rs+=1
		for /f "delims=, tokens=1" %%D in ("%%A") do set "owned_rs[!rs!]=%%D"
	)
) )
for /l %%A in (1 1 !rs!) do echo.!owned_rs[%%A]!
exit /b 0
