@echo off
setlocal enabledelayedexpansion
set "URL=https://auth.riotgames.com/api/v1/authorization"
cd /d "%~dp0"
cd.. 
for /F "tokens=1,2 delims=#" %%a in ('"prompt #$H#$E# & echo on & for %%b in (1) do rem"') do (
  set "ESC=%%b"A
)
if not "%~1"=="openchecker" exit /b 1
if "%~3"=="" exit /b 1
for /f "delims=" %%A in (settings\settings.txt) do set "%%A"
set default_bar=
set /a bar_progress=1
set bar=
for /l %%A in (1 1 11) do set "default_bar=!default_bar! "
set "folder=%~3"
set bar=
for /l %%B in (1 1 !bar_progress!) do set "bar=!bar!="
echo=Obtaining LCU tokens...                     
for %%1 in ("!bar_progress!") do echo=[!bar!!default_bar:~0,-%%~1!]
echo=!ESC![3F
:startloop
set /a fail+=1
tasklist.exe /fi "ImageName eq LeagueClientUX.exe" /fo csv 2>NUL | find.exe /I "LeagueClientUX.exe">NUL
if !errorlevel! equ 1 (
	start "" "!riot_client_services!" --launch-product=league_of_legends --launch-patchline=live --headless
	timeout /T 2 /NOBREAK >nul
	goto :startloop
)
if not "%~4"=="noterm" timeout /T 13 /NOBREAK >nul
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
set "lcu=curl.exe --no-progress-meter -s  --insecure -H "Authorization: Basic !lcu_session_token!" -H "Content-Type: application/json" -H "Accept: application/json""


if not "%~4"=="noterm" call "modules\kill_ux.bat"
for /f "delims=" %%A in ('findstr.exe "summoner[" "%~2"') do (
	set /a acc_cr+=1
)
set /a acc_cr+=1
) 
call :req "/lol-login/v1/login-platform-credentials"

for /f "delims=" %%A in ('powershell.exe -Command "$json = '!ESCAPED_JSON_STRING!' | ConvertFrom-Json; Write-Output ($json.username.ToString())"') do set "login_username=%%A"
if "%~4"=="noterm" (
	set "ask=%~5"
) else set "ask=%~4"
if "!ask!"=="" (
	echo=Would you like to also add password to obtain last password change date and exact creation date?
	echo=Type "no" if not, otherwise type/copy your password.
	set /p "password=> "
) else (
	for /F "delims=: tokens=1,2" %%A in ("%~5") do (
		set "password=%%~B"
	)
)
if /i "!password!"=="no" set "pw=no"




pushd "%temp%"
set /a bar_progress+=1
set bar=
for /l %%B in (1 1 !bar_progress!) do set "bar=!bar!="
echo=Checking for bans...                     
for %%1 in ("!bar_progress!") do echo=[!bar!!default_bar:~0,-%%~1!]
echo=!ESC![3F
for /f "delims=" %%A in ('!lcu! --no-progress-meter -s  -w "%%{http_code}" --output /dev/null -X GET "!lcu_api!/lol-player-behavior/v1/ban"') do (
	if "%%A"=="200" (
		!lcu! --no-progress-meter -s  -X GET "!lcu_api!/lol-player-behavior/v1/ban" -o ban.json
		for /F "delims=" %%B in ('powershell -Command "$json = Get-Content -Path 'ban.json' | ConvertFrom-Json; $unixTime = $json.timeUntilBanExpires / 10000 - 11644473600000; $banDate = if ($json.timeUntilBanExpires -eq 18446744073709551615) { 'Permanent' } else { [datetime]::FromFileTimeUtc($json.timeUntilBanExpires).ToUniversalTime() }; Write-Output ($json.isPermaBan,$json.reason,$banDate -join ',')"
') do (
			popd
			md "accounts\!folder!\acc_!acc_cr!"
			echo=%%B,%~2> "accounts\!folder!\acc_!acc_cr!\is_banned.txt"
			del /F /q ban.json 2>nul >nul
			exit /b 5
		)
	)
)
popd
md "acc_!acc_cr!"
set /a bar_progress+=1
set bar=
for /l %%B in (1 1 !bar_progress!) do set "bar=!bar!="
echo=Exporting skins...                     
for %%1 in ("!bar_progress!") do echo=[!bar!!default_bar:~0,-%%~1!]
echo=!ESC![3F
2>nul >nul (
del /f /q "modules\skins.txt" 
del /f /q "user_skins.txt" 
del /f /q "skins_parsed.json" 
del /f /q "test.txt" 
del /f /q "hextechloot.txt"
del /f /q "matches.txt" 
del /f /q "ranks.txt"
del /f /q "session.json"
del /f /q "xpboost.json"
)
pushd "modules"
if not exist skins.json curl.exe --no-progress-meter -s  "https://raw.communitydragon.org/latest/plugins/rcp-be-lol-game-data/global/default/v1/skins.json" -o "skins.json"
!lcu! -X GET "!lcu_api!/lol-inventory/v2/inventory/CHAMPION_SKIN" -o skins.txt
powershell.exe -file "Extract_Skins_And_Obtain_Date.ps1" >> "user_skins.txt"
powershell.exe -file "Replace_SkinID_Skin_Name.ps1"
2>nul >nul move "account_skins.txt" "..\acc_!acc_cr!"
2>nul >nul del /f /q "user_skins.txt"
popd
set /a bar_progress+=1
set bar=
for /l %%B in (1 1 !bar_progress!) do set "bar=!bar!="
echo=Exporting inventory info...                     
for %%1 in ("!bar_progress!") do echo=[!bar!!default_bar:~0,-%%~1!]
echo=!ESC![3F
!lcu! -X GET "!lcu_api!/lol-inventory/v1/inventory?inventoryTypes=%%5B%%22SUMMONER_ICON%%22%%5D" -o data.json
for /f "delims=" %%A in ('powershell.exe -Command "$data = Get-Content -Path 'data.json' | ConvertFrom-Json; $data.Count"') do (
	set "icon_count=%%A"
)

!lcu! -X GET "!lcu_api!/lol-inventory/v1/inventory?inventoryTypes=%%5B%%22SPELL_BOOK_PAGE%%22%%5D" -o data.json
for /f "delims=, tokens=1,2" %%A in ('powershell.exe -Command "$json = Get-Content -Path 'data.json' | ConvertFrom-Json; $count = $json.quantity; $date = [datetime]::ParseExact($json.purchaseDate, 'yyyyMMddTHHmmss.fffZ', $null).ToString('yyyy-MM-dd HH:mm:ss'); Write-Output (\"$count,$date\")"
') do (
	for /f "tokens=1,*" %%B in ("%%A") do (
		set "rune_page_count=%%B"
		set "rune_page_date=%%C"
	)
)
!lcu! -X GET "!lcu_api!/lol-inventory/v1/inventory?inventoryTypes=%%5B%%22EMOTE%%22%%5D" -o data.json
for /f "delims=" %%A in ('powershell.exe -Command "(Get-Content -Path 'data.json' | ConvertFrom-Json | Where-Object {$_.inventoryType -eq 'EMOTE'}).Count"') do set "emote_count=%%A"
!lcu! -X GET "!lcu_api!/lol-inventory/v1/inventory?inventoryTypes=%%5B%%22WARD_SKIN%%22%%5D" -o data.json
for /f "delims=" %%A in ('powershell.exe -command "$json = Get-Content -Path 'data.json' | ConvertFrom-Json; $wardSkins = $json | Where-Object { $_.inventoryType -eq 'WARD_SKIN' }; $wardSkins.Count"') do set "ward_count=%%A"
!lcu! -X GET "!lcu_api!/lol-active-boosts/v1/active-boosts" -o "xpboost.json"
for /f "delims=" %%A in ('powershell.exe -command "$xpBoostJsonPath = 'xpboost.json'; $xpBoostContent = Get-Content -Path $xpBoostJsonPath -Raw | ConvertFrom-Json; $xpBoostEndDate = [datetime]::Parse($xpBoostContent.xpBoostEndDate).ToString('yyyy-MM-dd HH:mm:ss'); Write-Output $xpBoostEndDate"') do set "xp_boost=%%A"
(
echo=account-!acc_cr!-start
echo=password[!acc_cr!]=!password!
echo.ward_count[!acc_cr!]=!ward_count!
echo.icon_count[!acc_cr!]=!icon_count!
echo.emote_count[!acc_cr!]=!emote_count!
echo.rune_page_count[!acc_cr!]=!rune_page_count! 
echo.rune_page_date[!acc_cr!]=!rune_page_date!
echo.xp_boost[!acc_cr!]=!xp_boost!
)>>"%~2"
if "!pw!"=="no" goto :skip
2>nul >nul curl.exe -X POST "https://auth.riotgames.com/api/v1/authorization" ^
    -H "User-Agent: RiotClient/58.0.0.4640299.4552318 (Windows;10;;Professional, x64)" ^
    -H "Accept-Language: en-US,en;q=0.9" ^
    -H "Accept: application/json, text/plain, */*" ^
    -d "{\"acr_values\":\"urn:riot:bronze\", \"claims\":\"\", \"client_id\":\"riot-client\", \"nonce\":\"oYnVwCSrlS5IHKh7iI16oQ\", \"redirect_uri\":\"http://localhost/redirect\", \"response_type\":\"token id_token\", \"scope\":\"openid link ban lol_region\"}" ^
    -H "Content-Type: application/json" ^
    -c "cookies.txt"
curl.exe --no-progress-meter -X PUT "https://auth.riotgames.com/api/v1/authorization" ^
    -H "User-Agent: RiotClient/58.0.0.4640299.4552318 (Windows;10;;Professional, x64)" ^
    -H "Accept-Language: en-US,en;q=0.9" ^
    -H "Accept: application/json, text/plain, */*" ^
    -H "Content-Type: application/json" ^
    -d "{\"language\": \"en_US\", \"password\": \"!password!\", \"remember\": \"true\", \"type\": \"auth\", \"username\": \"!login_username!\"}" ^
    -b cookies.txt ^
    -o "output.txt"

for /f "delims=" %%A in (output.txt) do set "Str=%%A"
for /f "tokens=2 delims=#" %%a in ("!str!") do for /f "tokens=1 delims=&" %%b in ("%%~a") do set "accessTokenPart=%%b"
set "accessToken=!accessTokenPart:*access_token=!"
set "accessToken=!accessToken:~1!"
curl.exe --no-progress-meter -X GET "https://auth.riotgames.com/userinfo" ^
    -H "User-Agent: RiotClient/58.0.0.4640299.4552318 (Windows;10;;Professional, x64)" ^
    -H "Accept-Language: en-US,en;q=0.9" ^
    -H "Accept: application/json, text/plain, */*" ^
    -H "Authorization: Bearer !accessToken!" ^
    -o "userinfo.txt"
for /f "delims=- tokens=1,2,3" %%A in ('powershell.exe -Command "$obj = ConvertFrom-Json -InputObject (Get-Content userinfo.txt -Raw); $createdDate = ([DateTimeOffset]::FromUnixTimeMilliseconds($obj.acct.created_at)).ToString('dd/MM/yyyy HH:mm:ss'); $pwChangedDate = ([DateTimeOffset]::FromUnixTimeMilliseconds($obj.pw.cng_at)).ToString('dd/MM/yyyy HH:mm:ss'); $platformID = $obj.original_platform_id; Write-Output \""$createdDate"-"$pwChangedDate"-"$platformID"\""
') do (
	(echo=creation_date[!acc_cr!]=%%~A
	echo=original_creation_region[!acc_cr!]=%%~C
	echo=password_change_date[!Acc_cr!]=%%~B)>>"%~2"
)
:skip

2>nul del /f /q "data.json"
set /a bar_progress+=1
set bar=
for /l %%B in (1 1 !bar_progress!) do set "bar=!bar!="
echo=Requesting player loot, ranked stats, friends...                     
for %%1 in ("!bar_progress!") do echo=[!bar!!default_bar:~0,-%%~1!]
echo=!ESC![3F
!lcu!  -X GET "!lcu_api!/lol-loot/v1/player-loot" -o hextechloot.txt
!lcu!  -X GET "!lcu_api!/lol-champions/v1/owned-champions-minimal" -o test.txt
!lcu!  -X GET "!lcu_api!/lol-match-history/v1/products/lol/current-summoner/matches" -o matches.txt
!lcu!  -X GET "!lcu_api!/lol-ranked/v1/current-ranked-stats" -o ranks.txt
!lcu!  -X GET "!lcu_api!/lol-login/v1/session" -o session.json
!lcu!  -X GET "!lcu_api!/lol-store/v1/giftablefriends" -o friendlist.json
!lcu!  -X GET "!lcu_api!/lol-summoner/v1/current-summoner" -o summoner.json
set /a bar_progress+=1
set bar=
for /l %%B in (1 1 !bar_progress!) do set "bar=!bar!="
echo=Parsing all information...                                          
for %%1 in ("!bar_progress!") do echo=[!bar!!default_bar:~0,-%%~1!]
echo=!ESC![3F
powershell.exe -file "modules\Check_Prime_Capsules_Count.ps1" >> "acc_!acc_cr!\prime_capsules.txt"
powershell.exe -file "modules\Obtain_Champion_List_And_Obtain_Date.ps1" >> "acc_!acc_cr!\user_champions.txt"
powershell.exe -file "modules\Parse_Matches.ps1" >> "acc_!acc_cr!\last_match.txt"
powershell.exe -file "modules\Parse_Rank.ps1" >> "acc_!acc_cr!\ranked.txt"
powershell.exe -file "modules\Decode_JWT.ps1" >> "acc_!acc_cr!\jwt_info.txt"
powershell.exe -file "modules\Parse_friendlist.ps1" >> "acc_!acc_cr!\friendlist.txt"
powershell.exe -file "modules\Parse_ID.ps1" >> "acc_!acc_cr!\id.txt"
call :req "/lol-email-verification/v1/email"
for /f "tokens=1,2 delims=," %%A in ('powershell.exe -Command "$json = '!ESCAPED_JSON_STRING!' | ConvertFrom-Json; Write-Output ($json.email + ',' + $json.emailVerified)"') do (
	set "email=%%A"
	set "emailVerified=%%B"
)
call :req "/lol-honor-v2/v1/profile"
for /f "tokens=1,2 delims=," %%A in ('powershell.exe -Command "$json = '!ESCAPED_JSON_STRING!' | ConvertFrom-Json; Write-Output ($json.checkpoint.ToString() + ',' + $json.honorLevel)"') do (
	set "checkpoint=%%A"
	set "honorlevel=%%B"
)

!lcu! -X GET "!lcu_api!/lol-inventory/v1/wallet/rp" -o wallet.json
powershell.exe -file "modules\Wallet_Parse.ps1">>"acc_!acc_cr!\wallet.txt"


set /a bar_progress+=1
set bar=
for /l %%B in (1 1 !bar_progress!) do set "bar=!bar!="
echo=Checking ranked restriction, creation country, summoner name...                     
for %%1 in ("!bar_progress!") do echo=[!bar!!default_bar:~0,-%%~1!]
echo=!ESC![3F
call :req "/lol-leaver-buster/v1/ranked-restriction"
for /f "delims=" %%A in ('powershell.exe -Command "$json = '!ESCAPED_JSON_STRING!' | ConvertFrom-Json; Write-Output ($json.punishedgamesremaining.ToString())"') do set "ranked_restriction=%%A"
call :req "/lol-collections/v1/inventories/chest-eligibility"
for /f "delims=" %%A in ('powershell.exe -Command "$json = '!ESCAPED_JSON_STRING!' | ConvertFrom-Json; Write-Output ($json.earnablechests.ToString())"') do set "earnablechests=%%A"
for /f "delims=" %%A in ('!lcu! --silent -X GET !lcu_api!/lol-collections/v1/inventories/local-player/champion-mastery-score') do (
	set "champion_mastery_score=%%A"
	if not "!champion_mastery_score:errorCode=!"=="!champion_mastery_score!" set "champion_mastery_score=Not found"
)
call :req "/lol-missions/v1/data" 

for /f "delims=" %%A in ('powershell.exe -Command "$json = '!ESCAPED_JSON_STRING!' | ConvertFrom-Json; Write-Output ($json.level.ToString())"') do set "level=%%A"

call :req "/lol-chat/v1/me"

set "ESCAPED_JSON_STRING=!JSON_STRING:\=\\!"
set "ESCAPED_JSON_STRING=!ESCAPED_JSON_STRING:"=\"!"
for /f "tokens=1,2,3,4,5,6,7,8,9 delims=," %%A in ('powershell.exe -Command "$json = ConvertFrom-Json -InputObject '!ESCAPED_JSON_STRING!'; Write-Output ($json.gameName, $json.lol.rankedLeagueDivision, $json.lol.rankedLeagueQueue, $json.lol.rankedLeagueTier, $json.platformId, $json.icon, $json.lol.challengeCrystalLevel, $json.lol.challengePoints, $json.gameTag -join ',')"') do (
	set "summoner_name=%%A"
	set "div=%%B"
	set "mode=%%C"
	set "rank=%%D"
	set "icon_profile=%%F"
	set "challenge_lvl=%%G"
	set "challenge_pts=%%H"
	set "riot_disc=%%I"
)
for /f "delims=" %%A in ('powershell.exe -Command "$json = ConvertFrom-Json '!ESCAPED_JSON_STRING!'; Write-Output ($json.gameName)"') do set "gameName=%%A"
for /f "delims=" %%B in ('powershell.exe -Command "$json = ConvertFrom-Json '!ESCAPED_JSON_STRING!'; Write-Output ($json.gameTag)"') do set "gameTag=%%B"
set /a bar_progress+=1
set bar=
for /l %%B in (1 1 !bar_progress!) do set "bar=!bar!="
echo=Parsing ranks and counting skins, champions...                                          
for %%1 in ("!bar_progress!") do echo=[!bar!!default_bar:~0,-%%~1!]
echo=!ESC![3F
call :req "/riotclient/region-locale"
for /f "delims=" %%A in ('powershell.exe -Command "$json = ConvertFrom-Json '!ESCAPED_JSON_STRING!'; Write-Output $json.region"') do set "region=%%A"
REM set "gameName=!gameName: =_!"
REM set "gameTag=!gameTag: =_!"
set skins_amount=0
set champs_amount=0
for /f "delims=" %%A in (acc_!acc_cr!\account_skins.txt) do (
	set /a skins_amount+=1
)
for /F "delims=" %%A in (acc_!acc_cr!\user_champions.txt) do (
	set /a champs_amount+=1
)
call "modules\rare_skins_check.bat" "!acc_cr!">>"acc_!acc_cr!\rare_skins.txt"
set /a bar_progress+=1
set bar=
for /l %%B in (1 1 !bar_progress!) do set "bar=!bar!="
echo=Parsing JWT token...                                          
for %%1 in ("!bar_progress!") do echo=[!bar!!default_bar:~0,-%%~1!]
echo=!ESC![3F
(
echo=login[!acc_cr!]=!login_username!
echo=summoner[!acc_cr!]=!gameName!#!gameTag!
echo=level[!acc_cr!]=!level!
echo=emailverified[!acc_cr!]=!emailverified!
echo=email[!acc_cr!]=!email!
echo=region[!acc_cr!]=!region!
echo=honorlevel[!acc_cr!]=!honorlevel!
echo=checkpoint[!acc_cr!]=!checkpoint!
echo=rankedrestriction[!acc_cr!]=!ranked_restriction!
echo=earnablechests[!acc_cr!]=!earnablechests!
echo=champion_mastery_score[!acc_cr!]=!champion_mastery_score!
echo=skinsamount[!acc_cr!]=!skins_amount!
echo=champsamount[!acc_cr!]=!champs_amount!
echo=export_date[!acc_cr!]=!date!
)>>"%~2"

powershell.exe -file "modules\Parse_SoloQ.ps1">>"acc_!acc_cr!\display_rank_solo.txt"
powershell.exe -file "modules\Parse_FlexQ.ps1">>"acc_!acc_cr!\display_rank_flex.txt"
2>nul >nul powershell.exe -file "modules\Sort_By_Date_Skins.ps1"  acc_!acc_cr!
for /f "delims=" %%A in ('curl.exe --no-progress-meter -s  -k -X GET "!lcu_api!/lol-rso-auth/v1/authorization/access-token" !lcu_headers!') do (
	echo=%%A>>tmp.json
)
for /f "delims=" %%B in ('powershell -Command "$obj = Get-Content -Path '.\tmp.json' | ConvertFrom-Json; Write-Output $obj.token"') do set "token=%%B"
2>nul del /f /q tmp.json
for /F "delims=" %%A in ('!lcu!  -X GET "!lcu_api!/lol-store/v1/getStoreUrl"') do set "store_url=%%~A"
set "headers=-H "Connection: keep-alive" -H "Authorization: Bearer !token!" -H "Content-Type: application/json" -H "Accept: application/json" -H "User-Agent: Mozilla/5.0 ^(Windows NT 6.2; WOW64^) AppleWebKit/537.36 ^(KHTML, like Gecko^) LeagueOfLegendsClient/14.4.562.1291 ^(CEF 91^) Safari/537.36""
set /a bar_progress+=1
set bar=
for /l %%B in (1 1 !bar_progress!) do set "bar=!bar!="
echo=Parsing TFT...                                          
for %%1 in ("!bar_progress!") do echo=[!bar!!default_bar:~0,-%%~1!]
echo=!ESC![3F
set /a bar_progress+=1
set bar=
for /l %%B in (1 1 !bar_progress!) do set "bar=!bar!="
echo=Parsing all TFT data...                                          
for %%1 in ("!bar_progress!") do echo=[!bar!!default_bar:~0,-%%~1!]
echo=!ESC![3F
for /f "delims=" %%A in ('!lcu! -X GET "!lcu_api!/lol-inventory/v1/inventory?inventoryTypes=%%5B%%22TFT_MAP_SKIN%%22%%5D"') do set "tft_map_skin_json=%%A"
set "tft_map_skin_json=!tft_map_skin_json:"=\"!"
powershell -Command "$json = '!tft_map_skin_json!'; $items = ConvertFrom-Json $json; foreach ($item in $items) { $itemId = $item.itemId; $purchaseDate = [datetime]::ParseExact($item.purchaseDate.Substring(0,19), 'yyyyMMddTHHmmss.fff', [System.Globalization.CultureInfo]::InvariantCulture).ToString('yyyy-MM-dd HH:mm:ss'); Write-Output (\"$itemId,$purchaseDate\") }" > "tmptft.txt"
powershell -Command "$tftMapJson = Get-Content -Path 'modules\tftmap.json' | ConvertFrom-Json; $hash = @{}; foreach ($item in $tftMapJson) { $hash[$item.itemId.ToString()] = $item.name }; $inputData = Get-Content -Path 'tmptft.txt'; $outputData = foreach ($line in $inputData) { $fields = $line -split ','; $itemId = $fields[0]; $purchaseDate = $fields[1]; if ($hash.ContainsKey($itemId)) { $itemName = $hash[$itemId]; \"$itemName,$purchaseDate\" } else { \"Unknown ItemId ($itemId),$purchaseDate\" } }; $outputData | Set-Content 'tmptft2.txt'"
del /f /q "tmptft.txt"
for /f "delims=" %%A in ('!lcu! -X GET "!lcu_api!/lol-inventory/v1/inventory?inventoryTypes=%%5B%%22COMPANION%%22%%5D"') do set "little_legends_json=%%A"
set "little_legends_json=!little_legends_json:"=\"!"
powershell -Command "$little_legends_tft = '!little_legends_json!' | ConvertFrom-Json; $tftcompanion = Get-Content 'modules\tftcompanion.json' | ConvertFrom-Json; $companionMap = @{}; $tftcompanion | ForEach-Object { $companionMap[$_.itemId] = $_.name }; $results = $little_legends_tft | ForEach-Object { $name = if ($companionMap.ContainsKey($_.itemId)) { $companionMap[$_.itemId] } else { 'Unknown ItemId (' + $_.itemId + ')' }; try { $dateObject = [datetime]::ParseExact($_.purchaseDate, 'yyyyMMddTHHmmss.fffZ', [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::AssumeUniversal); $parsedDate = $dateObject.ToString('yyyy-MM-dd HH:mm:ss'); } catch { $parsedDate = 'Invalid Date Format'; } [PSCustomObject]@{ Name = $name; Date = $parsedDate; SortDate = $dateObject } }; $results | Sort-Object SortDate | ForEach-Object { $_.Name + ',' + $_.Date } | Out-File 'tftcompanion.txt'"



!lcu! -X GET "!lcu_api!/lol-inventory/v1/inventory?inventoryTypes=%%5B%%22SUMMONER_ICON%%22%%5D" > icons.json
for /f "delims=" %%A in ('!lcu! -X GET "!lcu_api!/lol-inventory/v1/inventory?inventoryTypes=%%5B%%22TFT_DAMAGE_SKIN%%22%%5D"') do set "tft_booms_json=%%A"
set tft_booms_json=!tft_booms_json:"=\"!"
powershell -Command "$booms_tft = '!tft_booms_json!' | ConvertFrom-Json; $tftbooms = Get-Content 'modules\tftbooms.json' | ConvertFrom-Json; $boomsMap = @{}; $tftbooms | ForEach-Object { $boomsMap[$_.itemId] = $_.name }; $output = $booms_tft | ForEach-Object { $name = if ($boomsMap.ContainsKey($_.itemId)) { $boomsMap[$_.itemId] } else { 'Unknown ItemId (' + $_.itemId + ')' }; $parsedDate = [datetime]::ParseExact($_.purchaseDate.Split('T')[0], 'yyyyMMdd', $null).ToString('yyyy-MM-dd'); $name + ',' + $parsedDate }; $output | Out-File 'output_booms.txt'"
set i=0
for /f "delims=, tokens=1,2" %%A in ('type "tmptft2.txt"') do (
	set /a i+=1
	(echo=tft_map_skin_name[!i!]=%%A
	echo=tft_map_skin_date[!i!]=%%B)>>"tftdata.txt"
)
echo=tft_map_skin_count=!i!>>"tftdata.txt"
set i=0
for /f "delims=, tokens=1,2" %%A in ('type "tftcompanion.txt"') do (
	set /a i+=1
	(echo=tft_little_legend_name[!i!]=%%A
	echo=tft_little_legend_date[!i!]=%%B)>>"tftdata.txt"
)
echo=tft_little_legend_count=!i!>>"tftdata.txt"
set i=0
for /f "delims=, tokens=1,2" %%A in ('type "output_booms.txt"') do (
	set /a i+=1
	(echo=tft_booms_name[!i!]=%%A
	echo=tft_booms_date[!i!]=%%B)>>"tftdata.txt"
)
echo=tft_booms_count=!i!>>"tftdata.txt"

powershell.exe -Command "$jsonArray = Get-Content 'icons.json' | ConvertFrom-Json; $results = $jsonArray | Where-Object { $_.purchaseDate -ne '' } | ForEach-Object { $itemId = $_.itemId; try { $dateObject = [datetime]::ParseExact($_.purchaseDate, 'yyyyMMddTHHmmss.fffZ', [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::AssumeUniversal); $formattedDate = $dateObject.ToString('yyyy-MM-dd HH:mm:ss'); } catch { $formattedDate = 'Invalid Date Format'; $dateObject = $null; } [PSCustomObject]@{ ItemId = $itemId; FormattedDate = $formattedDate; SortDate = $dateObject } } | Sort-Object SortDate; $results | ForEach-Object { Write-Output \"$($_.ItemId),$($_.FormattedDate)\"; }" > "unparsedicons.txt"

powershell.exe -Command "$icons = Get-Content 'modules\summoner_icons.json' -Raw | ConvertFrom-Json; $map = @{}; foreach ($icon in $icons) { $map[$icon.id.ToString()] = $icon.title; } $data = Import-Csv -Path 'unparsedicons.txt' -Header 'itemId','purchaseDate'; $data | ForEach-Object { $itemId = $_.itemId.Trim(); $name = if ($map.ContainsKey($itemId)) { $map[$itemId] } else { 'Not found: ' + $itemId }; \"$name*$($_.purchaseDate)\" } > 'parsedicons.txt'"


for /f "tokens=1,2 delims=*" %%A in ('type "parsedicons.txt"') do (
	set /a count+=1
	(echo=icon_name[!count!][!acc_cr!]=%%~A
	echo=icon_date[!count!][!acc_cr!]=%%~B)>>"%~2"
)
echo=icons[!acc_cr!]=!count!>>"%~2"


2>nul >nul (
del /f /q "modules\icons.json"
del /f /Q "unparsedicons.txt"
del /f /Q "parsedicons.txt"
del /f /q "tmptft2.txt"
del /f /q "tftcompanion.txt"
del /f /q "tmptft.txt"
del /f /q "output_booms.txt"
del /f /q "modules\skins.txt" 
del /f /q "user_skins.txt" 
del /f /q "skins_parsed.json" 
del /f /q "test.txt" 
del /f /q "hextechloot.txt"
del /f /q "modules\skins.json" 
del /f /q "matches.txt" 
del /f /q "ranks.txt" 
del /f /q "session.json"
del /F /q "summoner.json"
del /f /q "friendlist.json"
del /f /q "data.json"
del /f /q "purchase.json"
del /f /q "wallet.json"
del /f /q "xpboost.json"
del /f /q "output.txt"
del /f /Q "userinfo.txt"
del /f /q "cookies.txt"
del /F /Q "icons.json"
del /F /Q "skins_parsed.json"
) 
set /a skin=0
set /a champ=0
set /a rare=0
set /a fr=0
set /a gift=0
set /a purchase=0
set /a rcskin=0
set /a rcchamp=0
for /f "delims=, tokens=1,2,3,4,5" %%A in ('type "acc_!acc_cr!\wallet.txt"') do (
	(echo=rp[!acc_cr!]=%%A
	echo=be[!acc_cr!]=%%B
	echo=oe[!acc_cr!]=%%C
	echo=token[!acc_cr!]=%%D
	echo=me[!acc_cr!]=%%E)>>"%~2"
)
for /f "delims=, tokens=1,2,3" %%A in ('type "acc_!acc_cr!\id.txt"') do (
	(echo=accountid[!acc_cr!]=%%A
	echo=summonerid[!acc_cr!]=%%B
	echo=puuid[!acc_cr!]=%%C)>>"%~2"
)
for /f "delims== tokens=1,2" %%A in ('type "tftdata.txt"') do (
	echo=%%A[!acc_cr!]=%%B>>"%~2"
)
for /f "delims=, tokens=1,2" %%A in ('type "acc_!acc_cr!\friendlist.txt"') do (
	set /a fr+=1
	(echo=friend_name[!fr!][!acc_cr!]=%%~A
	echo=friend_date[!fr!][!acc_cr!]=%%~B)>>"%~2"
)
for /f "delims=, tokens=1,2,3,4,5" %%A in ('type "acc_!acc_cr!\jwt_info.txt"') do (
	(echo=creation_country[!acc_cr!]=%%A
	echo=security[!acc_cr!]=%%~B
	echo=verified_number[!acc_cr!]=%%C
	echo=age[!acc_cr!]=%%D)>>"%~2"
	set "creation_country=%%A"
	set "age=%%D"
)
for /f "delims=" %%A in ('type "acc_!acc_cr!\last_match.txt"') do (
	echo=last_match[!acc_cr!]=%%A>>"%~2"
)
for /f "delims== tokens=1,2" %%A in ('type "acc_!acc_cr!\ranked.txt"') do (
	echo=%%A[!acc_cr!]=%%B>>"%~2"
)
for /f "delims=" %%A in ('type "acc_!acc_cr!\prime_capsules.txt"') do echo=prime_capsules[!Acc_cr!]=%%~A>>"%~2"
for /f "delims=" %%A in ('type "acc_!acc_cr!\rare_skins.txt"') do (
	set /a rare+=1
	echo=rare_skin[!acc_cr!][!rare!]=%%~A>>"%~2"
)

for /f "delims=" %%A in ('type "acc_!acc_cr!\display_rank_solo.txt"') do (
	echo=rank[solo][!acc_cr!]=%%A>>"%~2"
)
for /f "delims=" %%A in ('type "acc_!acc_cr!\display_rank_flex.txt"') do (
	echo=rank[flex][!acc_cr!]=%%A>>"%~2"
)

for /f "delims=, tokens=1,2,3,4" %%A in ('type "acc_!acc_cr!\account_skins.txt"') do (
	set /a skin+=1
	set /a "rarity_count[!acc_cr!][%%D]+=1"
	set /a "legacy_count[!acc_cr!][%%C]+=1"
	if "!skin!"=="1" set "tmp=%%~A"
	(echo=skin_name[!skin!][!acc_cr!]=%%~A
	echo=skin_date[!skin!][!acc_cr!]=%%~B
	echo=skin_islegacy[!skin!][!acc_cr!]=%%~C
	echo=skin_rarity[!skin!][!acc_cr!]=%%~D)>>"%~2"
)
echo=skin_name[1][!Acc_cr!]=!tmp:~3!>>"%~2"

(
if /i "!rarity_count[%acc_cr%][klegendary]!"=="" (echo=rarity_count[%acc_cr%][klegendary]=0) else (echo=rarity_count[%acc_cr%][klegendary]=!rarity_count[%acc_cr%][klegendary]!)
if /i "!rarity_count[%acc_cr%][kmythic]!"=="" (echo=rarity_count[%acc_cr%][kmythic]=0) else (echo=rarity_count[%acc_cr%][kmythic]=!rarity_count[%acc_cr%][kmythic]!)
if /i "!rarity_count[%acc_cr%][knorarity]!"=="" (echo=rarity_count[%acc_cr%][knorarity]=0) else (echo=rarity_count[%acc_cr%][knorarity]=!rarity_count[%acc_cr%][knorarity]!)
if /i "!rarity_count[%acc_cr%][kepic]!"=="" (echo=rarity_count[%acc_cr%][kepic]=0) else (echo=rarity_count[%acc_cr%][kepic]=!rarity_count[%acc_cr%][kepic]!)
if /i "!rarity_count[%acc_cr%][krare]!"=="" (echo=rarity_count[%acc_cr%][krare]=0) else (echo=rarity_count[%acc_cr%][krare]=!rarity_count[%acc_cr%][krare]!)
if /i "!rarity_count[%acc_cr%][kultimate]!"=="" (echo=rarity_count[%acc_cr%][kultimate]=0) else (echo=rarity_count[%acc_cr%][kultimate]=!rarity_count[%acc_cr%][kultimate]!)
)>>"%~2"


(echo=legacy_count[!acc_cr!][True]=!legacy_count[%acc_cr%][True]!
echo=legacy_count[!acc_cr!][False]=!legacy_count[%acc_cr%][False]!)>>"%~2"

for /f "delims=, tokens=1,2" %%A in ('type "acc_!acc_cr!\user_champions.txt"') do (
	set /a champ+=1
	(echo=champ_name[!champ!][!acc_cr!]=%%~A
	echo=champ_date[!champ!][!acc_cr!]=%%~B)>>"%~2"
)

(echo=friendscount[!acc_cr!]=!fr!
echo=rare[!acc_cr!]=!rare!
echo=champsamount[!acc_cr!]=!champ!
echo=skinsamount[!acc_cr!]=!skin!)>>"%~2"

for /f "tokens=1,2" %%A in ('curl.exe --silent "http://worldtimeapi.org/api/timezone/Europe/London.txt"') do (
	if "%%A"=="utc_datetime:" (
		for /f "tokens=1 delims=-" %%C in ("%%B") do (
			set /a "birth_year=%%C - age"
		)
	)
)

for /f "delims=" %%A in ('curl.exe --silent  "https://restcountries.com/v3.1/alpha/!creation_country!?fields=name"') do (
	set "json_country=%%A"
)
pushd "%temp%"
set "json_country=!json_country:"=\"!"
for /f "delims=" %%A in ('powershell.exe -Command "$json = ConvertFrom-Json '!json_country!'; $officialName = $json.name.official; Write-Output $officialName"') do set "creation_country=%%A"
popd

(echo=parsed_country[!acc_cr!]=!creation_country!
echo=birth_year[!acc_cr!]=!birth_year!)>>"%~2"
echo=account-!acc_cr!-end>>"%~2"

(
del /f /q "acc_!acc_cr!"
rd /q /s "acc_!acc_cr!"
del /F /q "tftdata.txt" 
) 2>nul >nul
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

:req
for /f "delims=" %%A in ('!lcu! --no-progress-meter -s  -X GET !lcu_api!%~1') do set "json_string=%%A"
set "ESCAPED_JSON_STRING=!JSON_STRING:"=\"!"
exit /b 0