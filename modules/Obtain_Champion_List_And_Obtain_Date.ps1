$jsonString = Get-Content -Path ".\test.txt" -Raw
$jsonArray = ConvertFrom-Json -InputObject $jsonString

# Create an empty array to store objects with necessary data
$results = @()

foreach ($obj in $jsonArray) {
    $name = $obj.name

    $timestamp = $null
    if ($null -ne $obj.ownership.rental -and $null -ne $obj.ownership.rental.purchaseDate) {
        $timestamp = $obj.ownership.rental.purchaseDate
    } elseif ($null -ne $obj.purchased) {
        $timestamp = $obj.purchased
    }

    $purchaseDate = 'null'  # Default value if no valid timestamp
    if ($null -ne $timestamp -and $timestamp -lt [Int64]::MaxValue) {
        try {
            $epochStart = New-Object DateTime(1970, 1, 1, 0, 0, 0, [DateTimeKind]::Utc)
            $dateObject = $epochStart.AddMilliseconds([double]$timestamp).ToLocalTime()
            $purchaseDate = $dateObject.ToString('yyyy-MM-dd HH:mm:ss')
        } catch {
            $purchaseDate = 'Invalid Timestamp'
        }
    }

    $owned = $obj.ownership.owned

    # Only store the data if the item is owned
    if ($owned -eq $true) {
        $results += [PSCustomObject]@{
            Name = $name
            PurchaseDate = $purchaseDate
            DateObject = $dateObject  # Store the actual DateTime object for sorting
        }
    }
}

# Sort the results by the DateObject and output the formatted Name and PurchaseDate
$results | Sort-Object DateObject | ForEach-Object {
    Write-Output "$($_.Name),$($_.PurchaseDate)"
}
