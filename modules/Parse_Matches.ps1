# Assuming the JSON content is stored in 'data.json'
$jsonContent = Get-Content -Path "matches.txt" -Raw
$data = $jsonContent | ConvertFrom-Json

# Extract the first game creation date
$firstGameCreationDate = $data.games.games[0].gameCreationDate

# Convert to [datetime] and format the output
$normalizedDate = [datetime]::Parse($firstGameCreationDate).ToLocalTime().ToString("yyyy-MM-dd HH:mm:ss")

Write-Output $normalizedDate