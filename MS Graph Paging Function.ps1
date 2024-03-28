$clientID = 'yourClientID'
$tenantId = 'yourTenantID'
$Clientsecret = 'yourSecret'


#Auth MS Graph API and Get Header
$tokenBody = @{  
    Grant_Type    = "client_credentials"  
    Scope         = "https://graph.microsoft.com/.default"  
    Client_Id     = $clientID  
    Client_Secret = $Clientsecret  
}   
$tokenResponse = Invoke-RestMethod -Uri "https://login.microsoftonline.com/$tenantID/oauth2/v2.0/token" -Method POST -Body $tokenBody  
$headers = @{
    "Authorization" = "Bearer $($tokenResponse.access_token)"
    "Content-type"  = "application/json"
}



function Get-AzureResourcePaging {
    param (
        $URL,
        $AuthHeader
    )
 
    # List Get all Apps from Azure

    $Response = Invoke-RestMethod -Method GET -Uri $URL -Headers $AuthHeader
    $Resources = $Response.value

    while ($null -ne $($Response."@odata.nextLink")) {
        $Response = (Invoke-RestMethod -Uri $($Response."@odata.nextLink") -Headers $AuthHeader -Method Get)
        $Resources += $Response.value
    }

    if ($null -eq $Resources) {
                $Resources = $Response
            }
    return $Resources
}



#Examples
$AllDevices = Get-AzureResourcePaging -URL "https://graph.microsoft.com/v1.0/devices" -AuthHeader $headers
$AllUsers = Get-AzureResourcePaging -URL "https://graph.microsoft.com/v1.0/users" -AuthHeader $headers
$AllApplications = Get-AzureResourcePaging -URL "https://graph.microsoft.com/v1.0/applications" -AuthHeader $headers

