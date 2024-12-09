# Read the JSON string from 'hextechloot.txt'
$jsonString = Get-Content -Path ".\hextechloot.txt" -Raw

# Convert the JSON string to a PowerShell object array
$jsonArray = ConvertFrom-Json -InputObject $jsonString

# Search for the item with lootId "CHEST_606"
$targetItem = $jsonArray | Where-Object { $_.lootId -eq "CHEST_606" }

# Check if the item was found and print its count
if ($null -ne $targetItem) {
    Write-Output $targetItem.count
} else {
    # If not found, print 0
    Write-Output "0"
}
