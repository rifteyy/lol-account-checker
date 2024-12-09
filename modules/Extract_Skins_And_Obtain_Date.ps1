# Read the JSON string from 'skins.txt'
$jsonString = Get-Content -Path ".\skins.txt" -Raw

# Convert the JSON string to a PowerShell object array
$jsonArray = ConvertFrom-Json -InputObject $jsonString

# Create an empty array to store objects with necessary data
$results = @()

foreach ($item in $jsonArray) {
    $itemId = $item.itemId
    $dateObject = $null  # Initialize as $null to handle invalid dates
    try {
        # Attempt to convert purchaseDate using ParseExact with a format specifier
        $dateObject = [datetime]::ParseExact($item.purchaseDate, "yyyyMMddTHHmmss.fffZ", [Globalization.CultureInfo]::InvariantCulture, [Globalization.DateTimeStyles]::AssumeUniversal)
        $purchaseDate = $dateObject.ToString("yyyy-MM-dd HH:mm:ss")
    } catch {
        # Handle cases where purchaseDate might not be in the expected format
        $purchaseDate = "Invalid Date Format"
    }

    # Add each item as a custom object to the results array
    $results += [PSCustomObject]@{
        ItemId = $itemId
        PurchaseDate = $purchaseDate
        DateObject = $dateObject  # Keep the actual DateTime object for sorting
    }
}

# Sort the results by the DateObject, and then print the formatted ItemId and PurchaseDate
$results | Sort-Object DateObject | ForEach-Object {
    Write-Output "$($_.ItemId),$($_.PurchaseDate)"
}
