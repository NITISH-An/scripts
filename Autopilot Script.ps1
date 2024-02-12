# Credential to be hidden
$clientId = "7b2f0500-d6b5-4ce8-b19d-461f40b7d47d"
$tenantId = "ea2db08c-1eea-4886-80fb-c5a6135ca88e"
$clientSecret = "mZ.8Q~PPrbzx2wRzD1oF1cOLIlPE-A_o.BP~mdgO"
$scopes = "https://graph.microsoft.com/.default"

# Get access token using client credentials flow
$tokenEndpoint = "https://login.microsoftonline.com/$tenantId/oauth2/v2.0/token"
$body = @{
    client_id     = $clientId
    scope         = $scopes
    client_secret = $clientSecret
    grant_type    = "client_credentials"
}
$accessToken = Invoke-RestMethod -Uri $tokenEndpoint -Method Post -Body $body

# Path to the CSV file
$csvFilePath = "C:\Users\Public\Documents\Autopilot Devices for Deletion\Newfile_SerialNumber.csv"

# Read serial numbers from the CSV file
$serialNumbers = Import-Csv -Path $csvFilePath | Select-Object -ExpandProperty SerialNumber

# Initialize an array to store results
$deviceIds = @()


    # Your existing code...

# Loop through each serial number
foreach ($serialNumber in $serialNumbers) 
{
    # Construct the query to search for Autopilot devices based on serial number
    $query = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities"

    # Make the request to Microsoft Graph API
    $response = Invoke-RestMethod -Uri $query -Headers @{"Authorization" = "Bearer $($accessToken.access_token)"} -Verbose
    $filteredResponse = $response.value | Where-Object { $_.serialNumber -eq $serialNumber }

    # Check if any devices are found
    if ($filteredResponse.serialNumber.count -gt 0) {
        # Loop through each device
        foreach ($device in $filteredResponse.value) {
            # Construct the URL for the delete request
            $deleteUrl = "https://graph.microsoft.com/beta/deviceManagement/windowsAutopilotDeviceIdentities/$($device.id)"

            # Make the delete request to Microsoft Graph API
           Invoke-RestMethod -Uri $deleteUrl -Method Delete -Headers @{"Authorization" = "Bearer $($accessToken.access_token)"} -Verbose
        }
    } else {
        Write-Host "Device with serial number $($serialNumber) not found."
    }
}
