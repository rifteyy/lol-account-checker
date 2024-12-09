# Define the paths for easy reference and modification
$skinsJsonPath = "skins.json"
$userSkinsTxtPath = "user_skins.txt"
$skinsParsedJsonPath = "skins_parsed.json"
$userSkinsModifiedTxtPath = "account_skins.txt"

# Step 0: Initial cleanup - Remove temporary files if they exist at the start
if (Test-Path -Path $skinsParsedJsonPath) {
    Remove-Item -Path $skinsParsedJsonPath
}

# Step 1: Parse the original JSON and create skins_parsed.json
$jsonContent = Get-Content -Path $skinsJsonPath -Raw
$skins = $jsonContent | ConvertFrom-Json

# Create skins_parsed.json
Out-File -FilePath $skinsParsedJsonPath -InputObject "" -Encoding UTF8

# Dictionary to hold skinId and skin properties
$skinDictionary = @{}

foreach ($skin in $skins.PSObject.Properties) {
    $skinDictionary[$skin.Value.id.ToString()] = @{
        "name" = $skin.Value.name
        "isLegacy" = $skin.Value.isLegacy
        "rarity" = $skin.Value.rarity
    }
}

# Step 2: Replace Skin IDs with Names in user_skins.txt and append isLegacy and rarity
$userSkinsContent = Get-Content -Path $userSkinsTxtPath
$processedContent = @()

foreach ($line in $userSkinsContent) {
    $parts = $line -split ",", 2
    $skinId = $parts[0]
    $restOfLine = $parts[1]

    if ($skinDictionary.ContainsKey($skinId)) {
        $skinInfo = $skinDictionary[$skinId]
        $newLine = $skinInfo["name"] + "," + $restOfLine + "," + $skinInfo["isLegacy"].ToString() + "," + $skinInfo["rarity"]
        $processedContent += $newLine
    }
}

$processedContent | Out-File -FilePath $userSkinsModifiedTxtPath -Encoding UTF8