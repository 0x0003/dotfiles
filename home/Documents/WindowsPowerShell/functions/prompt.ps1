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
  if ($env:HTTP_PROXY) { Write-Host "`` " -NoNewline -ForegroundColor yellow }
  Write-Host "λ." -NoNewline -ForegroundColor darkblue
  return " "
}

