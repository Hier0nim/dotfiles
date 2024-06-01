# ---------------------------------------------------------------------------------------------
# Script to set up and maintain desired state configuration for environment
# ---------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------
# Functions
# ---------------------------------------------------------------------------------------------

# Function to ensure chezmoi is installed via winget and initialize it if necessary
function EnsureAndInitializeChezmoi
{
    EnsureWingetPackage "twpayne.chezmoi"
    $chezmoiPath = "$env:USERPROFILE\AppData\Local\Microsoft\WinGet\Links\chezmoi.exe"
    $chezmoiDir = "$env:USERPROFILE\.local\share\chezmoi"

    if (Test-Path $chezmoiPath)
    {
        if (-not (Test-Path "$chezmoiDir\.git"))
        {
            & $chezmoiPath init --apply Hier0nim
        }
        & $chezmoiPath update -v
    } else
    {
        Write-Host "Chezmoi executable not found: $chezmoiPath" -ForegroundColor Red
    }
}

# Function to check if a command exists
function CheckCommand
{
    param (
        [string]$Command
    )
    return $null -ne (Get-Command $Command -ErrorAction SilentlyContinue)
}

# Function to ensure a package is installed via winget
function EnsureWingetPackage
{
    param (
        [string]$PackageId
    )
    if ($null -eq (CheckCommand $PackageId))
    {
        winget install --id=$PackageId --accept-package-agreements --accept-source-agreements
    }
}

# Function to register Task Scheduler tasks for specified programs to run at user login
function RegisterStartupTask
{
    param (
        [string]$TaskName,
        [string]$Description,
        [string]$ExecutablePath,
        [string]$Arguments
    )

    if ($null -eq (Test-Path $ExecutablePath))
    {
        Write-Host "Executable not found: $ExecutablePath" -ForegroundColor Red
        return
    }

    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existingTask)
    {
        $currentAction = ($existingTask.Actions | Where-Object { 
                $_.Executable -eq $ExecutablePath -and $_.Arguments -eq $Arguments 
            })

        $currentTrigger = ($existingTask.Triggers | Where-Object { 
                $_.AtStartup -and $_.Enabled -eq $true 
            })

        $currentPrincipal = $existingTask.Principal.UserId -eq "BUILTIN\Users" -and $existingTask.Principal.LogonType -eq "Interactive" -and $existingTask.Principal.RunLevel -eq "Limited"
        $currentSettings = $existingTask.Settings.AllowStartIfOnBatteries -and $existingTask.Settings.DontStopIfGoingOnBatteries -and $existingTask.Settings.StartWhenAvailable

        if ($currentAction -and $currentTrigger -and $currentPrincipal -and $currentSettings)
        {
            Write-Host "Task $TaskName is already registered with the correct properties." -ForegroundColor Yellow
            return
        }

        Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
    }

    try
    {
        if ([string]::IsNullOrEmpty($Arguments))
        {
            $action = New-ScheduledTaskAction -Execute $ExecutablePath
        } else
        {
            $action = New-ScheduledTaskAction -Execute $ExecutablePath -Argument $Arguments
        }

        $trigger = New-ScheduledTaskTrigger -AtLogOn
        $Principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest
        $settings = New-ScheduledTaskSettingsSet `
            -AllowStartIfOnBatteries `
            -DontStopIfGoingOnBatteries `
            -StartWhenAvailable `
            -RestartInterval (New-TimeSpan -Minutes 1) `
            -RestartCount 3 `
            -ExecutionTimeLimit (New-TimeSpan -Seconds 0)

        Register-ScheduledTask -TaskName $TaskName -Description $Description -Action $action -Trigger $trigger -Principal $principal -Settings $settings

        Write-Host "Task $TaskName has been registered." -ForegroundColor Green
    } catch
    {
        Write-Host "Failed to register task $TaskName $_" -ForegroundColor Red
    }
}

# Function to apply winget configuration if the state doesn't match
function ApplyWingetConfigIfNecessary
{
    param (
        [string]$ConfigPath
    )

    if ($null -eq (Test-Path $ConfigPath))
    {
        Write-Host "Winget configuration file not found: $ConfigPath" -ForegroundColor Yellow
        return
    }

    # Test the current system state against the configuration file
    $testOutput = winget configure test --file $ConfigPath --accept-configuration-agreements --disable-interactivity

    if ($testOutput -match "System is not in the described configuration state")
    {
        Write-Host "Configuration update required: $ConfigPath" -ForegroundColor Yellow
        winget configure --file $ConfigPath --accept-configuration-agreements --disable-interactivity
    } else
    {
        Write-Host "Current state matches configuration: $ConfigPath" -ForegroundColor Green
    }
}

# Function to ensure packages listed in XML configuration are installed
function EnsureWingetPackages
{
    param (
        [string]$ConfigPath
    )

    if ($null -eq (Test-Path $ConfigPath))
    {
        Write-Host "Winget package configuration file not found: $ConfigPath" -ForegroundColor Yellow
        return
    }

    # Load the XML configuration
    [xml]$config = Get-Content $ConfigPath

    # Get the list of currently installed packages once
    $installedPackages = winget list | Select-Object -Skip 1 | ForEach-Object { 
        $_.Trim() -split '\s{2,}' | Select-Object -Index 1
    }

    # Iterate over each package in the XML
    foreach ($package in $config.Configuration.Packages.Package)
    {
        $packageId = $package.id
        if ($installedPackages -notcontains $packageId)
        {
            Write-Host "Package $packageId requires installation." -ForegroundColor Yellow
            winget install --id $packageId --accept-package-agreements --accept-source-agreements
        } else
        {
            Write-Host "Package $packageId is already installed." -ForegroundColor Green
        }
    }
}

# ---------------------------------------------------------------------------------------------
# START
# ---------------------------------------------------------------------------------------------

# Ensure winget is installed
if ($null -eq (CheckCommand winget))
{
    Write-Host "Winget is not installed. Please install winget manually from the Microsoft Store." -ForegroundColor Red
    exit 1
}

# Upgrade existing packages
# winget upgrade --all

# ---------------------------------------------------------------------------------------------
# Install and initialize dotfiles manager
# ---------------------------------------------------------------------------------------------

EnsureAndInitializeChezmoi

# ---------------------------------------------------------------------------------------------
# Winget setup using DSC configurations
# ---------------------------------------------------------------------------------------------

# Paths to winget YAML DSC configuration files 
$wingetYAMLConfigs = @(
    "$env:USERPROFILE\.win-setup\winget_settings.yaml"
)

foreach ($config in $wingetYAMLConfigs)
{
    ApplyWingetConfigIfNecessary -ConfigPath $config
}

# Paths to winget XML configuration files
$wingetXMLConfigs = @(
    "$env:USERPROFILE\.win-setup\winget_utils.config",
    "$env:USERPROFILE\.win-setup\winget_development.config"
)

foreach ($config in $wingetXMLConfigs)
{
    EnsureWingetPackages -ConfigPath $config
}

# ---------------------------------------------------------------------------------------------
# Chocolatey packages installations
# ---------------------------------------------------------------------------------------------

if ($null -eq (CheckCommand choco))
{
    winget install --id="Chocolatey.Chocolatey" --accept-package-agreements --accept-source-agreements
}

$chococonfigfile = "$env:userprofile\.win-setup\chocolatey.config"
if (Test-Path $chococonfigfile)
{
    choco install $chococonfigfile -y
} else
{
    Write-Host "Chocolatey configuration file not found: $chococonfigfile" -ForegroundColor Yellow
}

# ---------------------------------------------------------------------------------------------
# Powershell modules install
# ---------------------------------------------------------------------------------------------

Set-PSRepository PSGallery -InstallationPolicy Trusted

$psModules = @("ZLocation", "PSFzf", "Terminal-Icons", "PSReadLine")
foreach ($module in $psModules)
{
    if ($null -eq (Get-Module -ListAvailable -Name $module))
    {
        Install-Module -Name $module -Scope CurrentUser -Force
    }
}

# ---------------------------------------------------------------------------------------------
# Ensure scoop is installed
# ---------------------------------------------------------------------------------------------

if ($null -eq (CheckCommand scoop))
{
    Invoke-Expression (New-Object System.Net.WebClient).DownloadString('https://get.scoop.sh')
}

# ---------------------------------------------------------------------------------------------
# Register Task Scheduler tasks for specified programs to run at user login
# ---------------------------------------------------------------------------------------------

$tasks = @(
    @{Name="ButteryTaskBar"; Description="Runs Buttery TaskBar at user login"; Path="$env:USERPROFILE\.win-setup\buttery-taskbar.exe"; Args=""},
    @{Name="GlazeWM"; Description="Runs GlazeWM at user login"; Path="$env:USERPROFILE\AppData\Local\Microsoft\WinGet\Packages\glzr-io.glazewm_Microsoft.Winget.Source_8wekyb3d8bbwe\glazewm.exe"; Args=""},
    @{Name="Sripts_GlazeWM"; Description="Runs GlazeWM at user login"; Path="$env:USERPROFILE\.glaze-wm\scripts\init.exe"; Args=""},
    @{Name="Throttlestop"; Description="Runs ThrottleStop at user login"; Path="C:\ProgramData\chocolatey\lib\throttlestop\tools\throttlestop\ThrottleStop.exe"; Args=""},
    @{Name="FlowLauncher"; Description="Runs FlowLauncher at user login"; Path="$env:USERPROFILE\AppData\Local\FlowLauncher\Flow.Launcher.exe"; Args=""},
    @{Name="SpaceFn"; Description="Runs SpaceFn at user login"; Path="$env:USERPROFILE\AppData\Local\Programs\AutoHotkey\v2.0.12\AutoHotkey64.exe"; Args="$env:USERPROFILE\.win-setup\SpaceFn.ahk"}
)

foreach ($task in $tasks)
{
    RegisterStartupTask -TaskName $task.Name -Description $task.Description -ExecutablePath $task.Path -Arguments $task.Args
}

# ---------------------------------------------------------------------------------------------
# Execute unelevated section
# ---------------------------------------------------------------------------------------------

$shell = "powershell"
if (Get-Command pwsh -ErrorAction SilentlyContinue)
{
    $shell = "pwsh"
}
Start-Process -NoNewWindow -FilePath $shell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$env:USERPROFILE\.win-setup\setup_unelevated.ps1`"" -Wait

# ---------------------------------------------------------------------------------------------
# Ask for restart confirmation
# ---------------------------------------------------------------------------------------------

$restartResponse = Read-Host "Configuration complete. Do you want to restart the machine now? (y/n)"
if ($restartResponse -eq 'y' -or $restartResponse -eq 'Y')
{
    Write-Host "Restarting the machine..." -ForegroundColor Green
    Restart-Computer -Force
} else
{
    Write-Host "Restart skipped. Please restart the machine manually to apply all changes." -ForegroundColor Yellow
}
