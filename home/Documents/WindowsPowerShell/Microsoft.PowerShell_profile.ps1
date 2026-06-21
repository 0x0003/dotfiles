# banner
#Clear-Host
#Write-Host 'Powershell' $PsVersionTable.PSVersion '-' (Get-date)
#Write-Host ''

# source other parts
. "$PSScriptRoot\functions\prompt.ps1"
. "$PSScriptRoot\functions\cd.ps1"
. "$PSScriptRoot\alias.ps1"
. "$PSScriptRoot\functions\prx.ps1"

# readline options
Set-PSReadlineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit
Set-PSReadLineOption -EditMode Emacs
Set-PSReadlineOption -BellStyle None

