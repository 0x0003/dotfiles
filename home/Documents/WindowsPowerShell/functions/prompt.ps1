function global:prompt {
  $path = switch -Wildcard ($executionContext.SessionState.Path.CurrentLocation.Path) {
    "$HOME" { "~" }
    "$HOME\*" { $executionContext.SessionState.Path.CurrentLocation.Path.Replace($HOME, "~") }
    default { $executionContext.SessionState.Path.CurrentLocation.Path }
  }

  Set-PSReadLineOption -Colors @{ Command = 'gray' }

  Write-Host " " -NoNewline
  Write-Host $path -NoNewline -ForegroundColor gray
  Write-Host " " -NoNewline
  if ($env:HTTP_PROXY) {
    $right = "``"
    $raw = $Host.UI.RawUI
    $pos = $raw.CursorPosition
    $raw.CursorPosition = New-Object System.Management.Automation.Host.Coordinates ($raw.WindowSize.Width - $right.Length), $pos.Y
    Write-Host $right -NoNewline -ForegroundColor yellow
    $raw.CursorPosition = $pos
  }
  Write-Host "λ." -NoNewline -ForegroundColor darkblue
  return " "
}

