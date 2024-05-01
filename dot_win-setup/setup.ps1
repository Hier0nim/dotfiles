# Upgrade existing packages
winget upgrade --all

# Install dotfiles manager
winget install --id=twpayne.chezmoi --accept-package-agreements --accept-source-agreements

# Initialize dotfiles manager
$chezmoiPath = "$env:USERPROFILE\AppData\Local\Microsoft\WinGet\Links\chezmoi.exe"
& $chezmoiPath init --apply Hier0nim

# Winget setup
winget configuration -f $env:USERPROFILE\.win-setup\winget_dsc\winget_settings.yaml --accept-configuration-agreements --disable-interactivity
winget configuration -f $env:USERPROFILE\.win-setup\winget_dsc\winget_utils.yaml --accept-configuration-agreements --disable-interactivity
winget configuration -f $env:USERPROFILE\.win-setup\winget_dsc\winget_development.yaml --accept-configuration-agreements --disable-interactivity

# Chocolatey installations
choco install $env:USERPROFILE\.win-setup\chocolatey.config

# Powershell modules install
Set-PSRepository PSGallery -InstallationPolicy Trusted
Install-Module ZLocation -Scope CurrentUser
Install-Module -Name PSFzf
Install-Module -Name Terminal-Icons -Repository PSGallery
Install-Module PSReadLine

# ---------------------------------------------------------------------------------------------
# Register Task Scheduler tasks for specified programs to run at user login
# ---------------------------------------------------------------------------------------------

function Register-StartupTask {
    param(
        [string]$TaskName,
        [string]$Description,
        [string]$ExecutablePath
    )
    $Action = New-ScheduledTaskAction -Execute $ExecutablePath
    $Trigger = New-ScheduledTaskTrigger -AtLogon
    $Principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest

    Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName $TaskName -Description $Description -Principal $Principal |
        Get-ScheduledTask -TaskName $TaskName |
        ForEach-Object {
            $_.Settings.DisallowStartIfOnBatteries = $false
            $_.Settings.StopIfGoingOnBatteries = $false
            $_.Settings.DisallowStartIfOnBatteries = $false
            $_.Settings.StopIfGoingOnBatteries = $false
            Set-ScheduledTask -InputObject $_
        }
}

Register-StartupTask "ButteryTaskBar" "Runs Buttery TaskBar at user login" "$env:USERPROFILE\.win-setup\buttery-taskbar.exe"
Register-StartupTask "GlazeWM" "Runs GlazeWM at user login" "$env:USERPROFILE\AppData\Local\Microsoft\WinGet\Packages\glzr-io.glazewm_Microsoft.Winget.Source_8wekyb3d8bbwe\glazewm.exe"
Register-StartupTask "Throttlestop" "Runs ThrottleStop at user login" "C:\ProgramData\chocolatey\lib\throttlestop\tools\throttlestop\ThrottleStop.exe"
Register-StartupTask "FlowLauncher" "Runs FlowLauncher at user login" "$env:USERPROFILE\AppData\Local\FlowLauncher\Flow.Launcher.exe"
