(Get-Content -Path 'wallet.json' | ConvertFrom-Json | ForEach-Object { $_.RP, $_.lol_blue_essence, $_.lol_orange_essence, $_.lol_worlds23_token, $_.lol_mythic_essence } | ForEach-Object { if ($_ -eq $null) { 0 } else { $_ } }) -join ','
