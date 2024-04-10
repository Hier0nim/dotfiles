oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\dracula.omp.json" | Invoke-Expression
$PSStyle.FileInfo.Directory = ""
$env:EDITOR='nvim'

Import-Module -Name Terminal-Icons
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
