# ---------------------------------------------------------------------------------------------
# Unelevated section of the setup 
# ---------------------------------------------------------------------------------------------

$scoopPackagesFile = "$env:USERPROFILE\.win-setup\scoop.config"
if (Test-Path $scoopPackagesFile)
{
    Write-Host "Installing scoop packages" -ForegroundColor Green
    [xml]$scoopXml = Get-Content $scoopPackagesFile
    foreach ($package in $scoopXml.packages.package)
    {
        scoop install $package.id
    }
} else
{
    Write-Host "Scoop configuration file not found: $scoopPackagesFile" -ForegroundColor Yellow
}
