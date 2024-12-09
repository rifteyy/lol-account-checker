# Define the path to the summoner.json file
$summonerJsonPath = "summoner.json"

# Read the JSON content from 'summoner.json'
$jsonContent = Get-Content -Path $summonerJsonPath -Raw

# Convert the JSON string to a PowerShell object
$summoner = ConvertFrom-Json -InputObject $jsonContent

# Extract the accountId, summonerId, and puuid
$accountId = $summoner.accountId
$summonerId = $summoner.summonerId
$puuid = $summoner.puuid

# Output accountId, summonerId, and puuid
Write-Output "$accountId,$summonerId,$puuid"
