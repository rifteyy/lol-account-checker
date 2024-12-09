# Define the path to the friendlist.json file
$friendListJsonPath = "friendlist.json"

# Check if the friendlist.json file exists
if (-not (Test-Path -Path $friendListJsonPath)) {
    Write-Error "The file $friendListJsonPath does not exist."
    exit
}

# Read the JSON content from 'friendlist.json'
$jsonContent = Get-Content -Path $friendListJsonPath -Raw

# Convert the JSON string to a PowerShell object array
$friendList = ConvertFrom-Json -InputObject $jsonContent

# Iterate over each object in the array to extract and modify nick and friendsSince
foreach ($friend in $friendList) {
    # Replace spaces with underscores in nick
    $nick = $friend.nick -replace ' ', '_'
    # Replace spaces with underscores in friendsSince
    $friendsSince = $friend.friendsSince -replace ' ', '_'

    # Output modified nick and friendsSince
    Write-Output "`"$nick`",`"$friendsSince`""
}
