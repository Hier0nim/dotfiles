# Upgrade existing packages
winget upgrade --all

winget install --id=twpayne.chezmoi --accept-package-agreements --accept-source-agreements
# Initialize dotfiles manager
$chezmoiPath = "$env:USERPROFILE\AppData\Local\Microsoft\WinGet\Links\chezmoi.exe"
& $chezmoiPath init --apply Hier0nim

# Winget setup
winget configuration -f $env:USERPROFILE\.win-setup\winget_dsc\winget_settings.yaml --disable-interactivity
winget configuration -f $env:USERPROFILE\.win-setup\winget_dsc\winget_utils.yaml --disable-interactivity
winget configuration -f $env:USERPROFILE\.win-setup\winget_dsc\winget_development.yaml --disable-interactivity

# Chocolatey installations
choco install $env:USERPROFILE\.win-setup\chocolatey.config

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
$Path = [System.Environment]::GetEnvironmentVariable("Path", [System.EnvironmentVariableTarget]::Machine)
$NewPath = "C:\Program Files (x86)\Microsoft Visual Studio\2022\BuildTools\VC\Tools\Llvm\x64\bin"
If (-Not $Path.Split(';').Contains($NewPath)) {
    $NewPath = $Path + ";" + $NewPath
    [System.Environment]::SetEnvironmentVariable("Path", $NewPath, [System.EnvironmentVariableTarget]::Machine)
}
