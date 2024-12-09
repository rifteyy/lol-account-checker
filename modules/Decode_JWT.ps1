# Read the JSON content from 'session.json'
$jsonContent = Get-Content -Path "session.json" -Raw
$data = $jsonContent | ConvertFrom-Json

# Extract the JWT from the idToken field
$jwt = $data.idToken

# Function to decode Base64Url to a readable string
function Decode-Base64UrlToText($base64Url) {
    # Convert Base64Url to Base64 by replacing URL specific characters and adding necessary padding
    $paddedBase64 = $base64Url -replace "-", "+" -replace "_", "/"
    switch ($paddedBase64.Length % 4) {
        2 { $paddedBase64 += "==" }
        3 { $paddedBase64 += "=" }
    }

    # Decode Base64 to bytes and then to string
    try {
        $base64Bytes = [Convert]::FromBase64String($paddedBase64)
        $text = [System.Text.Encoding]::UTF8.GetString($base64Bytes)
        return $text
    } catch {
        Write-Error "Failed to decode Base64Url string."
    }
}

# Split the JWT into its parts (Header, Payload, Signature)
$parts = $jwt -split '\.'

# Decode and display the header and payload
$header = Decode-Base64UrlToText $parts[0]
$payload = Decode-Base64UrlToText $parts[1]

# Assuming the rest of the script is unchanged and you have the $payload variable decoded

# Convert the payload from JSON string to an object
# Assuming the rest of the script is unchanged and you have the $payload variable decoded

# Convert the payload from JSON string to an object
$payloadObject = $payload | ConvertFrom-Json

# Extract the specific values
$country = $payloadObject.country
# Convert 'amr' array to a string with elements separated by commas without spaces and enclose in quotes
$amr = "`"$($payloadObject.amr -join ',')`""
$phone_number_verified = $payloadObject.phone_number_verified
$age = $payloadObject.age
$login_country = $payloadObject.login_country

# Print the extracted values on the same line
Write-Host "$country,$amr,$phone_number_verified,$age,$login_country"
