#region Parameters
[string]$LogPath = "D:\_SCOWorkingDir\PowerShell\Warranty Info" #Path to store the Lofgile
[string]$LogfileName = "GetWarranty" #FileName of the Logfile
[int]$DeleteAfterDays = 10 #Time Period in Days when older Files will be deleted

#endregion Parameters

#region Function
function Write-TechguyLog {
    [CmdletBinding()]
    param
    (
        [ValidateSet('DEBUG', 'INFO', 'WARNING', 'ERROR')]
        [string]$Type,
        [string]$Text
    )

    # Set logging path
    if (!(Test-Path -Path $logPath)) {
        try {
            $null = New-Item -Path $logPath -ItemType Directory
            Write-Verbose ("Path: ""{0}"" was created." -f $logPath)
        }
        catch {
            Write-Verbose ("Path: ""{0}"" couldn't be created." -f $logPath)
        }
    }
    else {
        Write-Verbose ("Path: ""{0}"" already exists." -f $logPath)
    }
    [string]$logFile = '{0}\{1}_{2}.log' -f $logPath, $(Get-Date -Format 'yyyyMMdd'), $LogfileName
    $logEntry = '{0}: <{1}> {2}' -f $(Get-Date -Format dd.MM.yyyy-HH:mm:ss), $Type, $Text
    Add-Content -Path $logFile -Value $logEntry
}
#endregion Function

Write-TechguyLog -Type INFO -Text "START Script"




#Clean Logs
Write-TechguyLog -Type INFO -Text "Clean Log Files"
$limit=(Get-Date).AddDays(-$DeleteAfterDays)
Get-ChildItem -Path $LogPath -Filter "*$LogfileName.log" | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force


Write-TechguyLog -Type INFO -Text "END Script"