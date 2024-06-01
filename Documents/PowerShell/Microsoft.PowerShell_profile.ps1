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
  Start-Sleep(5000)
  & "$env:USERPROFILE\.glaze-wm\scripts\init.exe"
}

Set-Alias -Name glaze -Value Invoke-Glaze

function Invoke-SpaceFn
{
  sudo "$env:USERPROFILE\.win-setup\SpaceFn.ahk"
}

Set-Alias -Name spacefn -Value Invoke-SpaceFn
