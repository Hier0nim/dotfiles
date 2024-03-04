# Winget installations
winget install --id=Git.Git --accept-package-agreements --accept-source-agreements
winget install --id=GitHub.GitHubDesktop --accept-package-agreements --accept-source-agreements
winget install --id=JetBrains.Rider --accept-package-agreements --accept-source-agreements
winget install --id=Neovim.Neovim --accept-package-agreements --accept-source-agreements
winget install --id=OpenJS.NodeJS --accept-package-agreements --accept-source-agreements
winget install --id=twpayne.chezmoi --accept-package-agreements --accept-source-agreements
winget install --id=Chocolatey.Chocolatey --accept-package-agreements --accept-source-agreements
winget install --id=glzr-io.glazewm --accept-package-agreements --accept-source-agreements
winget install --id=DEVCOM.JetBrainsMonoNerdFont --accept-package-agreements --accept-source-agreements
winget install --id=Microsoft.Powertoys --accept-package-agreements --accept-source-agreements
winget install --id=JanDeDobbeleer.OhMyPosh --accept-package-agreements --accept-source-agreements
winget install --id=Microsoft.Powershell --accept-package-agreements --accept-source-agreements
winget install --id=AutoHotkey.AutoHotkey --accept-package-agreements --accept-source-agreements
winget upgrade --all

# Chocolatey installations
choco install mingw -y
choco install make -y
choco install unzip -y
choco install vifm -y
choco install throttlestop -y

# Initialize dotfiles manager
chezmoi init --apply Hier0nim

# ---------------------------------------------------------------------------------------------
# Register Task Scheduler tasks for specified programs to run at user login

# Buttery TaskBar (Update the path as necessary)
$ButteryTaskBarPath = "$env:USERPROFILE\.win-setup\ButteryTaskBar\buttery-taskbar.exe"
$ActionButteryTaskBar = New-ScheduledTaskAction -Execute $ButteryTaskBarPath
$TriggerLogon = New-ScheduledTaskTrigger -AtLogon
$PrincipalHighest = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest

Register-ScheduledTask -Action $ActionButteryTaskBar -Trigger $TriggerLogon -TaskName "Run Buttery TaskBar at login" -Description "Runs Buttery TaskBar at user login" -Principal $PrincipalHighest

# GlazeWM
$GlazeWMPath = "$env:USERPROFILE\AppData\Local\Microsoft\WinGet\Packages\glzr-io.glazewm_Microsoft.Winget.Source_8wekyb3d8bbwe\glazewm.exe"
$ActionGlazeWM = New-ScheduledTaskAction -Execute $GlazeWMPath

Register-ScheduledTask -Action $ActionGlazeWM -Trigger $TriggerLogon -TaskName "Run GlazeWM at login" -Description "Runs GlazeWM at user login" -Principal $PrincipalHighest

# ThrottleStop
$ThrottleStopPath = "C:\ProgramData\chocolatey\lib\throttlestop\tools\throttlestop\ThrottleStop.exe"
$ActionThrottleStop = New-ScheduledTaskAction -Execute $ThrottleStopPath

Register-ScheduledTask -Action $ActionThrottleStop -Trigger $TriggerLogon -TaskName "Run ThrottleStop at login" -Description "Runs ThrottleStop at user login" -Principal $PrincipalHighest

# Modify each task to run on battery power
$taskNames = @("Run Buttery TaskBar at login", "Run GlazeWM at login", "Run ThrottleStop at login")

foreach ($taskName in $taskNames) {
    $task = Get-ScheduledTask -TaskName $taskName
    $task.Settings.DisallowStartIfOnBatteries = $false
    $task.Settings.StopIfGoingOnBatteries = $false
    Set-ScheduledTask -InputObject $task
}
