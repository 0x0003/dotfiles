# proxy state file
$prxState = Join-Path $PSScriptRoot "prx_state"
if (Test-Path $prxState) {
  $proxy = Get-Content $prxState
  $env:HTTP_PROXY = $proxy
  $env:HTTPS_PROXY = $proxy
  $env:http_proxy = $proxy
  $env:https_proxy = $proxy
  $env:all_proxy = $proxy
  [System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy($proxy)
  [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
  [System.Net.WebRequest]::DefaultWebProxy.BypassProxyOnLocal = $true
}

