# banner
#Clear-Host
#Write-Host 'Powershell' $PsVersionTable.PSVersion '-' (Get-date)
#Write-Host ''

$isElevated = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

# source other parts
. "$PSScriptRoot\env.ps1"
. "$PSScriptRoot\functions\prompt.ps1"
. "$PSScriptRoot\functions\cd.ps1"
. "$PSScriptRoot\alias.ps1"
. "$PSScriptRoot\functions\prx.ps1"
. "$PSScriptRoot\functions\mpd-kill.ps1"
. "$PSScriptRoot\functions\split-cuesheet.ps1"
# https://forums.powershell.org/t/powershell-add-type-creates-random-folders-in-temporary-folder/25615
if (-not $isElevated) {
    . "$PSScriptRoot\functions\set-wallpaper.ps1"
}

# readline options
Set-PSReadlineKeyHandler -Key Ctrl+d -Function DeleteCharOrExit
Set-PSReadLineOption -EditMode Emacs
Set-PSReadlineOption -BellStyle None

