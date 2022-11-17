$ErrorActionPreference = "Stop"
# Setting up Logfile 
$Logfile = "C:\windows\temp\VMware-SSL-VPN-Plus-Removal.log"
# Function to replace Write-Host by WriteLog
function WriteLog
{
Param ([string]$LogString)
$Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss")
$LogMessage = "$Stamp $LogString"
Add-content $LogFile -value $LogMessage
}
# Stop VMware running specific exe to keep things simple
WriteLog "Checking if VMware SSL VPN... exe are runing"
try {
    stop-process -name neosrv -force -ErrorAction Stop 
}
catch {
    WriteLog "neosrv not running"
}
try {
    stop-process -processname svpclient -ErrorAction Stop
}
catch {
    WriteLog "svpclient not running"
}
WriteLog "Now they should be stopped if they exist"
# Remove service
WriteLog "Removing Service"
try {
    $service = get-service "SSL VPN-Plus Service" -ErrorAction Stop
    switch ($service.status) {
        'Running' {
           WriteLog "$($service.name) is running"
            Stop-Service -displayname $service.name -force
           WriteLog "Now $($service.name) is stopped"         
        }
        'Stopped' {
            WriteLog "Now $($service.name) has already stopped"
        }
        Default {
            WriteLog "How did I get there?"
         }
    } 
    # Service should be stopped, now we remove it
    # We need to check the running PS version. I assume it will not be 7.x 
    if ($psversiontable.psversion.major -lt 6) {
        Get-Item "HKLM:\SYSTEM\CurrentControlSet\Services\VMware SSL VPN-Plus Client Adapter" | Remove-Item -Force
       }
       else {
        Remove-Service -Name "$($service.name)" -confirm:$false
       }
       Write-host "Now $($service.name) has been removed"
}
catch [System.Object] {
        WriteLog "The SSL VPN-Plus Service was not found`n"
        WriteLog "May be it was not installed or already removed`n"
        WriteLog $_.Exception`n
    }
catch {
    write-host "Removal issue?"
}
Finally {
        write-host "Now the service should be removed"
    }
# Done with the service.
#
# Get oem info before removing device
$drivers=Get-CimInstance win32_PnPSignedDriver
# We remove the device
WriteLog "Removing Device"
foreach ($dev in (Get-PnpDevice | Where-Object{$_.Name -eq "VMware SSL VPN-Plus Client Adapter"}))
{ 
    &"pnputil" /remove-device $dev.InstanceId -force
 }
WriteLog "Device removed"
# We remove the driver
WriteLog "Removing driver"
$thedriver="to be found"
# Looping from all to get the right one
foreach ($i in $drivers) {
    if ($i.friendlyname -eq "VMware SSL VPN-Plus Client Adapter") {$thedriver=$i.infname}}
#
if($thedriver -eq "to be found") {
    WriteLog "Driver not found"
}
else {
   WriteLog "$($thedriver) has been found and can be removed"
    pnputil /delete-driver $thedriver /uninstall /force 
}
WriteLog "The Driver should be gone now"
#
# Removing Registry entries if not already removed
# We do not process error, we carry on to next line
WriteLog "Removing Registry entries if still present"
remove-item -path "HKLM:\SYSTEM\CurrentControlSet\Services\SSL VPN-Plus Service\" -recurse -ErrorAction SilentlyContinue
remove-item -path "HKLM:\SOFTWARE\WOW6432Node\VMware, Inc.\" -recurse -ErrorAction SilentlyContinue
remove-item -path "HKLM:\SYSTEM\CurrentControlSet\Services\SVPadapter\" -recurse -ErrorAction SilentlyContinue
remove-item -path "HKLM:\SYSTEM\CurrentControlSet\Services\SVPRedirector.sys\" -recurse -ErrorAction SilentlyContinue
remove-item -path "HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall\SVPClient\" -recurse -ErrorAction SilentlyContinue
remove-item -path "HKCU:\SOFTWARE\VMware, Inc.\" -recurse -ErrorAction SilentlyContinue
WriteLog "All relevent registry entries should be gone"
# All (?) Relevant Registry entries removed
#
# Deleting shortcut, folders and some files
# We do not process error, we carry on to next line
WriteLog "Deleting Driver files if exist"
Remove-item "C:\Windows\System32\drivers\SVPadapter.sys" -force -erroraction SilentlyContinue
Remove-item "C:\Windows\System32\drivers\SVPRedirector.sys" -force -erroraction SilentlyContinue
WriteLog "Deleting Shortcut if exist"
Remove-Item "C:\Users\Public\Desktop\VMwareTray.*" -Recurse -force -erroraction SilentlyContinue
WriteLog "deleting VMware folders if exist"
#$path = "C:\Program Files (x86)\VMware\"
Remove-Item -R "C:\Program Files (x86)\VMware\*" -force -erroraction SilentlyContinue
Remove-Item -R "C:\Program Files (x86)\VMware" -force -erroraction SilentlyContinue
# All done
WriteLog "All done"
