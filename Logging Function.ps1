#region Parameters
[string]$LogPath = "D:\_SCOWorkingDir\PowerShell\Warranty Info" #Path to store the Lofgile, only local or Hybrid
[string]$LogfileName = "GetWarranty" #FileName of the Logfile, only local or Hybrid
[int]$DeleteAfterDays = 10 #Time Period in Days when older Files will be deleted, only local or Hybrid

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

    #Decide Platform
    $environment = "local"
    if ($env:AZUREPS_HOST_ENVIRONMENT) { $environment = "AAnoHybrid" }
    if ($env:AUTOMATION_WORKER_CERTIFICATE) { $environment = "AAHybrid" }
    
    if ($environment -eq "AAHybrid" -or $environment -eq "local") {
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
    elseif ($environment -eq "AAHybrid" -or $environment -eq "AAnoHybrid") {
        $logEntry = '{0}: <{1}> {2}' -f $(Get-Date -Format dd.MM.yyyy-HH:mm:ss), $Type, $Text

        switch ($Type) {
            INFO { Write-Output $logEntry }
            WARNING { Write-Warning $logEntry }
            ERROR { Write-Error $logEntry }
            DEBUG { Write-Output $logEntry }
            Default { Write-Output $logEntry }
        }
    }
}
#endregion Function
Write-TechguyLog -Type INFO -Text "START Script"

#Clean Logs
if ($environment -eq "AAHybrid" -or $environment -eq "local") {
    Write-TechguyLog -Type INFO -Text "Clean Log Files"
    $limit = (Get-Date).AddDays(-$DeleteAfterDays)
    Get-ChildItem -Path $LogPath -Filter "*$LogfileName.log" | Where-Object { !$_.PSIsContainer -and $_.CreationTime -lt $limit } | Remove-Item -Force
}

Write-TechguyLog -Type INFO -Text "END Script"