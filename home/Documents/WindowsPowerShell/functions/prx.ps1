function prx {
  $proxyaddress = 'http://127.0.0.1:2080'

  if ($global:proxy_is_on) {
    [System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.WebProxy($null)
    [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
    [System.Net.WebRequest]::DefaultWebProxy.BypassProxyOnLocal = $false
    Remove-Item Env:\http_proxy 2>$null
    Remove-Item Env:\https_proxy 2>$null
    $global:proxy_is_on = $false
    Write-Host "OFF"
  } else {
    [System.Net.WebRequest]::DefaultWebProxy = New-Object System.Net.Webproxy($proxyaddress)
    [System.Net.WebRequest]::DefaultWebProxy.Credentials = [System.Net.CredentialCache]::DefaultNetworkCredentials
    [System.Net.WebRequest]::DefaultWebProxy.BypassProxyOnLocal = $true
    $global:proxy_is_on = $true
    Write-Host "ON @ $proxyaddress"
  }
}

