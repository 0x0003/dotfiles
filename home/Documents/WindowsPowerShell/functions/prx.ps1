# toggle proxy in current and consecutive shell sessions
function prx {
  $proxyaddress = 'http://127.0.0.1:2080'
  $stateFile = Join-Path (Split-Path $PSScriptRoot -Parent) "prx_state"

  if ($env:HTTP_PROXY) {
    Remove-Item $stateFile -ErrorAction Ignore
    [System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy($null)
    [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
    [System.Net.WebRequest]::DefaultWebProxy.BypassProxyOnLocal = $false
    Remove-Item Env:HTTP_PROXY -ErrorAction SilentlyContinue
    Remove-Item Env:HTTPS_PROXY -ErrorAction SilentlyContinue
    Remove-Item Env:http_proxy -ErrorAction SilentlyContinue
    Remove-Item Env:https_proxy -ErrorAction SilentlyContinue
    Remove-Item Env:all_proxy -ErrorAction SilentlyContinue
    Remove-Item Env:SSH_PROXY -ErrorAction SilentlyContinue
    Write-Host "OFF"
  } else {
    Set-Content $stateFile -Value $proxyaddress
    [System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy($proxyaddress)
    [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
    [System.Net.WebRequest]::DefaultWebProxy.BypassProxyOnLocal = $true
    $env:HTTP_PROXY = $proxyaddress
    $env:HTTPS_PROXY = $proxyaddress
    $env:http_proxy = $proxyaddress
    $env:https_proxy = $proxyaddress
    $env:all_proxy = $proxyaddress
    $prx_uri = [uri]$proxyaddress
    $env:SSH_PROXY = "$($prx_uri.Host):$($prx_uri.Port)"
    Write-Host "ON @ $proxyaddress"
  }
}

