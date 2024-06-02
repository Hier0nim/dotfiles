# Define log file path
$logFilePath = "C:\Users\hieronim\merge_json_log.txt"

# Function to write log messages
function Write-Log
{
  param (
    [string]$message
  )
  Add-Content -Path $logFilePath -Value ("$(Get-Date -Format o) - $message")
}

# Function to read file from standard input
function Read-FileFromStdin
{
  $stdin = [System.Console]::In
  $allLines = @()
  while ($line = $stdin.ReadLine())
  {
    $allLines += $line
  }
  if (-not $allLines)
  {
    return $null
  }
  return $allLines -join [System.Environment]::NewLine
}

Write-Log "Reading JSON input from standard input..."
# Read JSON input from standard input
$CurrentFileContents = Read-FileFromStdin
Write-Log "Input JSON content read: $CurrentFileContents"

if ($CurrentFileContents -eq $null)
{
  Write-Log "No input provided via standard input."
  exit 1
}

# Filter out unwanted characters
$FilteredContents = $CurrentFileContents -replace "`e\[[0-9;]*[A-Za-z]", ""
Write-Log "Filtered JSON content: $FilteredContents"

try
{
  $jsonInput = $FilteredContents | ConvertFrom-Json
  Write-Log "Converted input JSON to PowerShell object."
} catch
{
  Write-Log "Failed to convert input to JSON."
  exit 1
}

# Path to settings base JSON file
$settingsBasePath = "C:\Users\hieronim\.local\share\chezmoi\AppData\Roaming\FlowLauncher\Settings\Settings_base.json"

if (-Not (Test-Path $settingsBasePath))
{
  Write-Log "Settings_base.json file not found at path: $settingsBasePath"
  exit 1
}

# Read JSON from Settings_base.json file
try
{
  $settingsBase = Get-Content -Raw -Path $settingsBasePath | ConvertFrom-Json
  Write-Log "Read and converted Settings_base.json to PowerShell object."
} catch
{
  Write-Log "Failed to read or convert Settings_base.json."
  exit 1
}

function Merge-Json
{
  param (
    [Parameter(Mandatory = $true)]
    [PSCustomObject] $Object1,

    [Parameter(Mandatory = $true)]
    [PSCustomObject] $Object2
  )

  foreach ($property in $Object2.PSObject.Properties)
  {
    if ($Object1.PSObject.Properties[$property.Name])
    {
      if ($Object1.$($property.Name) -is [PSCustomObject] -and $property.Value -is [PSCustomObject])
      {
        # Recursively merge nested objects
        $Object1.$($property.Name) = Merge-Json -Object1 $Object1.$($property.Name) -Object2 $property.Value
      } elseif ($Object1.$($property.Name) -is [System.Collections.IList] -and $property.Value -is [System.Collections.IList])
      {
        # Replace arrays if they are not equal
        if (-not ($Object1.$($property.Name) -eq $property.Value))
        {
          $Object1.$($property.Name) = $property.Value
        }
      } else
      {
        # Overwrite value
        $Object1.$($property.Name) = $property.Value
      }
    } else
    {
      # Add new property
      $Object1 | Add-Member -MemberType NoteProperty -Name $property.Name -Value $property.Value
    }
  }
  return $Object1
}

Write-Log "Merging JSON input with Settings_base.json..."
# Merge JSON input with settings base
try
{
  $mergedJson = Merge-Json -Object1 $jsonInput -Object2 $settingsBase
  Write-Log "Merging completed."
} catch
{
  Write-Log "Failed to merge JSON objects."
  exit 1
}

# Convert merged object to JSON and output it to standard output
try
{
  $mergedJsonString = $mergedJson | ConvertTo-Json -Depth 100
  Write-Log "Converted merged object to JSON."
  Write-Log "Outputting merged JSON."
  Write-Output $mergedJsonString
} catch
{
  Write-Log "Failed to convert merged object to JSON."
  exit 1
}
