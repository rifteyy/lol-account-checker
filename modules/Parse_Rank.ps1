# Assuming the JSON content is stored in a variable named $jsonContent
$jsonContent = Get-Content -Path "ranks.txt" -Raw
$data = $jsonContent | ConvertFrom-Json

# Function to print the ranked queue details to the console, including decay calculation
function Print-RankedQueueDetails {
    param (
        [PSCustomObject]$queueDetails,
        [string]$queueType
    )
    
    $rankString = "$queueType[rank]={0}" -f $queueDetails.tier
    $divisionString = "$queueType[division]={0}" -f $queueDetails.division
    $lpString = "$queueType[lp]={0}" -f $queueDetails.leaguePoints
    $winsString = "$queueType[wins]={0}" -f $queueDetails.wins
    $lossesString = "$queueType[losses]={0}" -f $queueDetails.losses
    $winRate = if ($queueDetails.wins + $queueDetails.losses -gt 0) { ($queueDetails.wins / ($queueDetails.wins + $queueDetails.losses) * 100) } else { 0 }
    $winRateString = "$queueType[winRate]={0:N2}%" -f $winRate
    $placementGamesRemainingString = "$queueType[placementGamesRemaining]={0}" -f $queueDetails.provisionalGamesRemaining
    $daysUntilDecayString = "$queueType[daysUntilDecay]={0}" -f $queueDetails.warnings.daysUntilDecay

    # Calculate decay date
    $decayDate = (Get-Date).AddDays($queueDetails.warnings.daysUntilDecay)
    $decayDateString = "$queueType[decayDate]={0}" -f $decayDate.ToString("yyyy-MM-dd")

    # Print each detail to the console
    Write-Host $rankString
    Write-Host $divisionString
    Write-Host $lpString
    Write-Host $winsString
    Write-Host $lossesString
    Write-Host $winRateString
    Write-Host $placementGamesRemainingString
    if ($queueDetails.warnings.daysUntilDecay) {
        Write-Host $daysUntilDecayString
        Write-Host $decayDateString
    }
    Write-Host "" # Print an empty line for better readability
}

# Print details for each queue type
Print-RankedQueueDetails -queueDetails $data.queueMap.RANKED_FLEX_SR -queueType "RANKED_FLEX_SR"
Print-RankedQueueDetails -queueDetails $data.queueMap.RANKED_SOLO_5x5 -queueType "RANKED_SOLO_5X5"
# Assuming RANKED_TFT, RANKED_TFT_DOUBLE_UP, and RANKED_TFT_TURBO might not have `warnings.daysUntilDecay`, you can conditionally print them if they exist
Print-RankedQueueDetails -queueDetails $data.queueMap.RANKED_TFT -queueType "RANKED_TFT"
Print-RankedQueueDetails -queueDetails $data.queueMap.RANKED_TFT_DOUBLE_UP -queueType "RANKED_TFT_DOUBLE_UP"
Print-RankedQueueDetails -queueDetails $data.queueMap.RANKED_TFT_TURBO -queueType "RANKED_TFT_TURBO"
