<#
A short Code Snippet to take care of O365 Connection Budget


Processing data from remote server outlook.office365.com failed with the following error message: [AuthZRequestId=4cdfc096-304e-49a5-b021-61ea00afd64d][FailureCategory=AuthZ-AuthorizationException] Fail to create runspace because you have exceeded your budget to create runspace. Please wait for 2 seconds.
Policy: CN=GlobalThrottlingPolicy_5b1a9400-faed-4949-ae04-029359ba2683,CN=Global Settings,CN=ExchangeLabs,CN=Microsoft Exchange,CN=Services,CN=Configuration,DC=eurprd01,DC=prod,DC=exchangelabs,DC=com;


#>


$Connected = $false
$MaxExit = $false
$MaxTryCount = 10
$Sleeptime = 10
$i = 0
    
do {
    try {
        Connect-ExchangeOnline -AppId $AppID -CertificateThumbprint $CertThumb -Organization $Org | Out-Null;
        $Connected = $true
    }
    catch {
        Start-Sleep -Seconds $Sleeptime
        $i++
        $Connected = $false
        if ($i -gt $MaxTryCount) { $MaxExit = $true }        
    }
} until (
    $Connected -or $MaxExit
)

#This part is for SCO, so the Activity shows a Warning
<#
if ($MaxExit)
{
    Connect-ExchangeOnline -AppId $AppID -CertificateThumbprint $CertThumb -Organization $Org | Out-Null;
}
#>