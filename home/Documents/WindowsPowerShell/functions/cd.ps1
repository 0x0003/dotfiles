# unix-like `cd` behavior
function ChangeDirectory {
  param([parameter(Mandatory=$false)] $path)
    if ( $PSBoundParameters.ContainsKey('path') ) {
      Set-Location $path
    } else {
      Set-Location $home
    }
}
Remove-Item alias:\cd
New-Alias cd ChangeDirectory

