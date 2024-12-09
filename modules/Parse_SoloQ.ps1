# Assuming the JSON content is stored in 'data.json'
$jsonContent = Get-Content -Path "ranks.txt" -Raw
$data = $jsonContent | ConvertFrom-Json

# Extract the highest rank (tier) and division from RANKED_SOLO_5x5
$highestTier = $data.queueMap.RANKED_SOLO_5x5.highestTier
$division = $data.queueMap.RANKED_SOLO_5x5.division

# Format the output
$output = "$highestTier $division"

# Print the output to the console on the same line
Write-Host "$output"
