# ---------------------------------------------------------------------------------------------
# Functions 
# ---------------------------------------------------------------------------------------------

function yy
{
  $tmp = [System.IO.Path]::GetTempFileName()
  yazi $args --cwd-file="$tmp"
  $cwd = Get-Content -Path $tmp
  if (-not [String]::IsNullOrEmpty($cwd) -and $cwd -ne $PWD.Path)
  {
    Set-Location -LiteralPath $cwd
  }
  Remove-Item -Path $tmp
}

# ---------------------------------------------------------------------------------------------
# oh-my-posh setup 
# ---------------------------------------------------------------------------------------------

oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\hotstick.minimal.omp.json" | Invoke-Expression

# ---------------------------------------------------------------------------------------------
# Setup 
# ---------------------------------------------------------------------------------------------
#
$PSStyle.FileInfo.Directory = ""
$env:EDITOR='nvim'

# ---------------------------------------------------------------------------------------------
# Modules 
# ---------------------------------------------------------------------------------------------

Import-Module -Name Terminal-Icons
Import-Module ZLocation
Import-Module "gsudoModule"
Import-Module ZLocation

if ($host.Name -eq 'ConsoleHost')
{
  Import-Module PSReadLine

  Set-PSReadLineKeyHandler -Key UpArrow -Function HistorySearchBackward
  Set-PSReadLineKeyHandler -Key DownArrow -Function HistorySearchForward
  Set-PSReadLineOption -PredictionSource HistoryAndPlugin
  Set-PSReadLineOption -HistorySearchCursorMovesToEnd
  Set-PSReadlineKeyHandler -Key Tab -Function MenuComplete
}

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'


# ---------------------------------------------------------------------------------------------
# Aliases 
# ---------------------------------------------------------------------------------------------

Set-Alias -Name which -Value Get-Command

function Invoke-NvimDBUI
{
  nvim -c "DBUI"
}
Set-Alias -Name dbui -Value Invoke-NvimDBUI

function Invoke-Glaze
{
  sudo "$env:USERPROFILE\AppData\Local\Microsoft\WinGet\Packages\glzr-io.glazewm_Microsoft.Winget.Source_8wekyb3d8bbwe\glazewm.exe"
  Start-Sleep(2)
  & "$env:USERPROFILE\.glaze-wm\scripts\init.exe"
}

Set-Alias -Name glaze -Value Invoke-Glaze

function Invoke-SpaceFn
{
  sudo "$env:USERPROFILE\.win-setup\SpaceFn.ahk"
}

Set-Alias -Name spacefn -Value Invoke-SpaceFn


function Invoke-Kanata
{
  # Stop the running process of Kanata
  $kanataProcess = Get-Process -Name "kanata" -ErrorAction SilentlyContinue
  if ($kanataProcess)
  {
    Stop-Process -Id $kanataProcess.Id -Force
  }

  # Run the Kanata script
  sudo "$env:USERPROFILE\.win-setup\Kanata\run-kanata.ps1"
}

Set-Alias -Name kanata -Value Invoke-Kanata



# Helper function for opening the Tortoise SVN GUI from a PowerShell prompt.
function Svn-Tortoise
{
  param(
    [Parameter(Mandatory=$false)]
    [ValidateSet("about", "log", "checkout", "update", "commit", "add", "revert", "cleanup", "merge", "repobrowser", "revisiongraph", "blame")]
    [string]$Command = "log",
    
    [Parameter(Mandatory=$false)]
    [string]$Path = "$pwd"  # Default to the current directory
  )
  <#
  Launches TortoiseSVN with the given command.
  Opens the log screen if no command is given.
  
  List of supported commands can be found at:
  http://tortoisesvn.net/docs/release/TortoiseSVN_en/tsvn-automation.html
#>
  TortoiseProc.exe /command:$Command /path:$Path
}

Set-Alias tsvn Svn-Tortoise
function Update-SVNAndExit
{
  Set-Location -Path (Resolve-Path ../..)
  svn update
  exit
}

Set-Alias usvn Update-SVNAndExit

function Edit-Tnsnames
{
  $filePath = "D:\oracle\product\19.0.0\server\network\admin\tnsnames.ora"
  if (Get-Command nvim -ErrorAction SilentlyContinue)
  {
    nvim $filePath
  } else
  {
    notepad $filePath
  }
}

Set-Alias etns Edit-Tnsnames
