# Set the WT_SESSION environment variable
$env:WT_SESSION = "0"

# Start a new minimized Windows Terminal session with specific arguments
Start-Process -WindowStyle Minimized -UseNewEnvironment -FilePath "wt.exe" -ArgumentList @(
    "new-tab"
    "--startingDirectory", "$env:USERPROFILE\.win-setup\kanata"
    "--", "$env:USERPROFILE\.win-setup\kanata\kanata.exe"
    "-dnc", "$env:USERPROFILE\.win-setup\kanata\kanata.kbd"
    "-p", "0.0.0.0:5588"
)

exit
