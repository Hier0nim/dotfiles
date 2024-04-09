oh-my-posh init pwsh --config "$env:POSH_THEMES_PATH\dracula.omp.json" | Invoke-Expression
$PSStyle.FileInfo.Directory = ""
$env:EDITOR='nvim'
