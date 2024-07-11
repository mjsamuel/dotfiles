Set-PSReadlineOption -EditMode vi
New-Alias c clear

Set-PsFzfOption -PSReadlineChordProvider 'Ctrl+t' -PSReadlineChordReverseHistory 'Ctrl+r'
fnm env --use-on-cd | Out-String | Invoke-Expression
