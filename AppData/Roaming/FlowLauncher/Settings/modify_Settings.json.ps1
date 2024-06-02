# Predefined base configuration
$baseConfig = @"
{
  "Hotkey": "Ctrl \u002B Alt \u002B Shift \u002B F5",
  "OpenResultModifiers": "Ctrl",
  "ColorScheme": "System",
  "ShowOpenResultHotkey": true,
  "PreviewHotkey": "F1",
  "Language": "en",
  "Theme": "Win11System",
  "UseDropShadowEffect": false,
  "QueryBoxFont": "Microsoft Sans Serif",
  "ResultFont": "Microsoft Sans Serif",
  "UseGlyphIcons": true,
  "UseAnimation": true,
  "UseSound": false,
  "UseClock": false,
  "UseDate": false,
  "FirstLaunch": false,
  "CustomExplorerIndex": 5,
  "CustomExplorerList": [
    {
      "Name": "Explorer",
      "Path": "explorer",
      "FileArgument": "/select, \u0022%f\u0022",
      "DirectoryArgument": "\u0022%d\u0022",
      "Editable": false
    },
    {
      "Name": "Total Commander",
      "Path": "C:\\Program Files\\totalcmd\\TOTALCMD64.exe",
      "FileArgument": "/O /A /S /T \u0022%f\u0022",
      "DirectoryArgument": "/O /A /S /T \u0022%d\u0022",
      "Editable": true
    },
    {
      "Name": "Directory Opus",
      "Path": "C:\\Program Files\\GPSoftware\\Directory Opus\\dopusrt.exe",
      "FileArgument": "/cmd Go \u0022%f\u0022 NEW",
      "DirectoryArgument": "/cmd Go \u0022%d\u0022 NEW",
      "Editable": true
    },
    {
      "Name": "Files",
      "Path": "Files",
      "FileArgument": "-select \u0022%f\u0022",
      "DirectoryArgument": "-select \u0022%d\u0022",
      "Editable": true
    },
    {
      "Name": "vifm",
      "Path": "C:\\ProgramData\\chocolatey\\bin\\vifm.exe",
      "FileArgument": "\u0022%d\u0022",
      "DirectoryArgument": "\u0022%d\u0022",
      "Editable": true
    },
    {
      "Name": "yazi",
      "Path": "%userprofile%:\\scoop\\shims\\yazi.exe",
      "FileArgument": "\u0022%d\u0022",
      "DirectoryArgument": "\u0022%d\u0022",
      "Editable": true
    }
  ],
  "CustomBrowserIndex": 0,
  "CustomBrowserList": [
    {
      "Name": "Default",
      "Path": "*",
      "PrivateArg": "",
      "EnablePrivate": false,
      "OpenInTab": true,
      "Editable": false
    },
    {
      "Name": "Google Chrome",
      "Path": "chrome",
      "PrivateArg": "-incognito",
      "EnablePrivate": false,
      "OpenInTab": true,
      "Editable": false
    },
    {
      "Name": "Mozilla Firefox",
      "Path": "firefox",
      "PrivateArg": "-private",
      "EnablePrivate": false,
      "OpenInTab": true,
      "Editable": false
    },
    {
      "Name": "MS Edge",
      "Path": "msedge",
      "PrivateArg": "-inPrivate",
      "EnablePrivate": false,
      "OpenInTab": true,
      "Editable": false
    }
  ],
  "HideOnStartup": true,
  "HideNotifyIcon": true,
  "LeaveCmdOpen": false,
  "HideWhenDeactivated": true,
  "SearchWindowScreen": "Focus",
  "SearchWindowAlign": "Center",
  "LastQueryMode": "Empty",
  "AnimationSpeed": "Medium",
  "CustomAnimationLength": 360,
  "PluginSettings": {
    "PythonExecutablePath": "",
    "NodeExecutablePath": "",
    "Plugins": {
      "0ECADE17459B49F587BF81DC3A125110": {
        "ID": "0ECADE17459B49F587BF81DC3A125110",
        "Name": "Browser Bookmarks",
        "Version": "3.1.5",
        "ActionKeywords": [
          "b"
        ],
        "Priority": 0,
        "Disabled": false
      },
      "CEA0FDFC6D3B4085823D60DC76F28855": {
        "ID": "CEA0FDFC6D3B4085823D60DC76F28855",
        "Name": "Calculator",
        "Version": "3.1.0",
        "ActionKeywords": [
          "*"
        ],
        "Priority": 0,
        "Disabled": false
      },
      "572be03c74c642baae319fc283e561a8": {
        "ID": "572be03c74c642baae319fc283e561a8",
        "Name": "Explorer",
        "Version": "3.1.5",
        "ActionKeywords": [
          "*",
          "doc:",
          "*",
          "*",
          "*"
        ],
        "Priority": 0,
        "Disabled": false
      },
      "6A122269676E40EB86EB543B945932B9": {
        "ID": "6A122269676E40EB86EB543B945932B9",
        "Name": "Plugin Indicator",
        "Version": "3.0.3",
        "ActionKeywords": [
          "?"
        ],
        "Priority": 0,
        "Disabled": false
      },
      "9f8f9b14-2518-4907-b211-35ab6290dee7": {
        "ID": "9f8f9b14-2518-4907-b211-35ab6290dee7",
        "Name": "Plugins Manager",
        "Version": "3.1.0",
        "ActionKeywords": [
          "pm"
        ],
        "Priority": 0,
        "Disabled": false
      },
      "b64d0a79-329a-48b0-b53f-d658318a1bf6": {
        "ID": "b64d0a79-329a-48b0-b53f-d658318a1bf6",
        "Name": "Process Killer",
        "Version": "3.0.4",
        "ActionKeywords": [
          "kill"
        ],
        "Priority": 0,
        "Disabled": false
      },
      "791FC278BA414111B8D1886DFE447410": {
        "ID": "791FC278BA414111B8D1886DFE447410",
        "Name": "Program",
        "Version": "3.2.0",
        "ActionKeywords": [
          "*"
        ],
        "Priority": 0,
        "Disabled": false
      },
      "D409510CD0D2481F853690A07E6DC426": {
        "ID": "D409510CD0D2481F853690A07E6DC426",
        "Name": "Shell",
        "Version": "3.2.0",
        "ActionKeywords": [
          "\u003E"
        ],
        "Priority": 0,
        "Disabled": false
      },
      "CEA08895D2544B019B2E9C5009600DF4": {
        "ID": "CEA08895D2544B019B2E9C5009600DF4",
        "Name": "System Commands",
        "Version": "3.1.1",
        "ActionKeywords": [
          "*"
        ],
        "Priority": 0,
        "Disabled": false
      },
      "0308FD86DE0A4DEE8D62B9B535370992": {
        "ID": "0308FD86DE0A4DEE8D62B9B535370992",
        "Name": "URL",
        "Version": "3.0.4",
        "ActionKeywords": [
          "*"
        ],
        "Priority": 0,
        "Disabled": false
      },
      "565B73353DBF4806919830B9202EE3BF": {
        "ID": "565B73353DBF4806919830B9202EE3BF",
        "Name": "Web Searches",
        "Version": "3.0.7",
        "ActionKeywords": [
          "*",
          "sc",
          "wiki",
          "findicon",
          "facebook",
          "twitter",
          "maps",
          "translate",
          "duckduckgo",
          "github",
          "gist",
          "gmail",
          "drive",
          "wolframalpha",
          "stackoverflow",
          "lucky",
          "image",
          "youtube",
          "bing",
          "yahoo",
          "bd"
        ],
        "Priority": 0,
        "Disabled": false
      },
      "5043CETYU6A748679OPA02D27D99677A": {
        "ID": "5043CETYU6A748679OPA02D27D99677A",
        "Name": "Windows Settings",
        "Version": "4.0.6",
        "ActionKeywords": [
          "s"
        ],
        "Priority": 0,
        "Disabled": false
      },
      "7D530704C68E4838896BBA5C4C1DE7DF": {
        "ID": "7D530704C68E4838896BBA5C4C1DE7DF",
        "Name": "Win Hotkey",
        "Version": "3.1.0",
        "ActionKeywords": [
          "*"
        ],
        "Priority": 0,
        "Disabled": false
      }
    }
  }
}
"@

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

# Function to merge two JSON objects
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

# Convert predefined base configuration to JSON object
$baseConfigJson = $baseConfig | ConvertFrom-Json

# Read JSON input from standard input
$CurrentFileContents = Read-FileFromStdin

if ($null -eq $CurrentFileContents)
{
  exit 1
}

# Filter out unwanted characters
$FilteredContents = $CurrentFileContents -replace "`e\[[0-9;]*[A-Za-z]", ""

try
{
  $jsonInput = $FilteredContents | ConvertFrom-Json
} catch
{
  exit 1
}

# Path to settings base JSON file
$settingsBasePath = "$env:USERPROFILE\.local\share\chezmoi\AppData\Roaming\FlowLauncher\Settings\Settings_base.json"

if (-Not (Test-Path $settingsBasePath))
{
  exit 1
}

# Read JSON from Settings_base.json file
try
{
  $settingsBase = Get-Content -Raw -Path $settingsBasePath | ConvertFrom-Json
} catch
{
  exit 1
}


# Merge JSON input with settings base and predefined base configuration
try
{
  $mergedJson = Merge-Json -Object1 $jsonInput -Object2 $settingsBase
  $finalMergedJson = Merge-Json -Object1 $baseConfigJson -Object2 $mergedJson
} catch
{
  exit 1
}

# Convert merged object to JSON and output it to standard output
try
{
  $mergedJsonString = $finalMergedJson | ConvertTo-Json -Depth 100
  Write-Output $mergedJsonString
} catch
{
  exit 1
}
