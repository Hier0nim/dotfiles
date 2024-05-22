# ---------------------------------------------------------------------------------------------
# Unelevated section of the setup 
# ---------------------------------------------------------------------------------------------

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
