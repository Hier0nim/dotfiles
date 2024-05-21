# ---------------------------------------------------------------------------------------------
# Script to set up and maintain desired state configuration for environment
# ---------------------------------------------------------------------------------------------

# ---------------------------------------------------------------------------------------------
# Functions
# ---------------------------------------------------------------------------------------------

# Check if the script is running with elevated privileges
function Test-IsElevated
{
    return ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
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
        [string]$ExecutablePath
    )

    if ($null -eq (Test-Path $ExecutablePath))
    {
        Write-Host "Executable not found: $ExecutablePath" -ForegroundColor Red
        return
    }

    $existingTask = Get-ScheduledTask -TaskName $TaskName -ErrorAction SilentlyContinue
    if ($existingTask)
    {
        $currentAction = ($existingTask.Actions | Where-Object { $_.Executable -eq $ExecutablePath })

        if ($currentAction)
        {
            Write-Host "Task $TaskName already exists with the correct path. No changes needed." -ForegroundColor Green
            return
        } else
        {
            Write-Host "Task $TaskName exists but with a different path. Updating task..." -ForegroundColor Yellow
            Unregister-ScheduledTask -TaskName $TaskName -Confirm:$false
        }
    }

    $Action = New-ScheduledTaskAction -Execute $ExecutablePath
    $Trigger = New-ScheduledTaskTrigger -AtLogon
    $Principal = New-ScheduledTaskPrincipal -UserId "$env:USERDOMAIN\$env:USERNAME" -LogonType Interactive -RunLevel Highest

    try
    {
        Register-ScheduledTask -Action $Action -Trigger $Trigger -TaskName $TaskName -Description $Description -Principal $Principal | Out-Null
        $task = Get-ScheduledTask -TaskName $TaskName
        $task.Settings.DisallowStartIfOnBatteries = $false
        $task.Settings.StopIfGoingOnBatteries = $false
        Set-ScheduledTask -InputObject $task
    } catch
    {
        Write-Host "Failed to register task: $TaskName" -ForegroundColor Red
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
    $installedPackages = winget list

    # Iterate over each package in the XML
    foreach ($package in $config.Configuration.Packages.Package)
    {
        $packageId = $package.id
        if ($installedPackages -notmatch $packageId)
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

# Relaunch the script with elevated privileges if not already elevated
if (-not (Test-IsElevated))
{
    $shell = "powershell"
    if (Get-Command pwsh -ErrorAction SilentlyContinue)
    {
        $shell = "pwsh"
    }
    Start-Process $shell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

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

EnsureWingetPackage "twpayne.chezmoi"
$chezmoiPath = "$env:USERPROFILE\AppData\Local\Microsoft\WinGet\Links\chezmoi.exe"
if (Test-Path $chezmoiPath)
{
    & $chezmoiPath init --apply Hier0nim
    & $chezmoiPath update -v
} else
{
    Write-Host "Chezmoi executable not found: $chezmoiPath" -ForegroundColor Red
}

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
# Register Task Scheduler tasks for specified programs to run at user login
# ---------------------------------------------------------------------------------------------

$tasks = @(
    @{Name="ButteryTaskBar"; Description="Runs Buttery TaskBar at user login"; Path="$env:USERPROFILE\.win-setup\buttery-taskbar.exe"},
    @{Name="GlazeWM"; Description="Runs GlazeWM at user login"; Path="$env:USERPROFILE\AppData\Local\Microsoft\WinGet\Packages\glzr-io.glazewm_Microsoft.Winget.Source_8wekyb3d8bbwe\glazewm.exe"},
    @{Name="Throttlestop"; Description="Runs ThrottleStop at user login"; Path="C:\ProgramData\chocolatey\lib\throttlestop\tools\throttlestop\ThrottleStop.exe"},
    @{Name="FlowLauncher"; Description="Runs FlowLauncher at user login"; Path="$env:USERPROFILE\AppData\Local\FlowLauncher\Flow.Launcher.exe"},
    @{Name="SpaceFn"; Description="Runs SpaceFn at user login"; Path="$env:USERPROFILE\.win-setup\SpaceFn.ahk"}
)

foreach ($task in $tasks)
{
    RegisterStartupTask -TaskName $task.Name -Description $task.Description -ExecutablePath $task.Path
}

# ---------------------------------------------------------------------------------------------
# UNELEVATED SECTION 
# ---------------------------------------------------------------------------------------------

# Ensure this fragment is run from an unelevated shell
if ($null -eq ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator))
{
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`" -NonElevatedFragment" -NoNewWindow
    exit
}

# ---------------------------------------------------------------------------------------------
# Scoop packages installations
# ---------------------------------------------------------------------------------------------

if ($args[0] -eq "NonElevatedFragment")
{
    $scoopPackagesFile = "$env:USERPROFILE\.win-setup\scoop.config"
    if (Test-Path $scoopPackagesFile)
    {
        [xml]$scoopXml = Get-Content $scoopPackagesFile
        $installedPackages = scoop list | Select-String -Pattern 'Name'
        foreach ($package in $scoopXml.packages.package)
        {
            if ($null -eq ($installedPackages -match $package.id))
            {
                scoop install $package.id
            }
        }
    } else
    {
        Write-Host "Scoop configuration file not found: $scoopPackagesFile" -ForegroundColor Yellow
    }
}

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
