# Read the content from skins.txt
$skins = Get-Content -Path "$args\account_skins.txt"

# Convert each line into a custom object with Date and OriginalLine properties
$skinsWithDates = $skins | ForEach-Object {
    $parts = $_ -split ','
    $date = [datetime]::ParseExact($parts[1], "yyyy-MM-dd HH:mm:ss", $null)
    [PSCustomObject]@{
        Date = $date
        OriginalLine = $_
    }
}

# Sort the objects by the Date property
$sortedSkins = $skinsWithDates | Sort-Object Date

# Extract the OriginalLine property and output to console or file
$sortedSkins | ForEach-Object { $_.OriginalLine } | Out-File -FilePath "$args\sorted_skins.txt"

# To display the sorted list in the console, remove the Out-File part
$sortedSkins | ForEach-Object { $_.OriginalLine }
