function split-cuesheet() {
  param(
      [Parameter(Mandatory=$true)]
      [string]$FilePath
  )

  $ErrorActionPreference = "Stop"

  $file = Resolve-Path $FilePath -ErrorAction Stop
  $dir = Split-Path $file -Parent

  $json = & ffprobe.exe -v quiet -show_entries format_tags=cuesheet -of json $file 2>$null | ConvertFrom-Json
  $cuesheet = $json.format.tags.cuesheet
  if (-not $cuesheet) {
      Write-Error "No embedded cuesheet found in $file"
      exit 1
  }

  $tracks = @()
  $currentTrack = $null

  foreach ($line in ($cuesheet -split "`r`n|`n")) {
      if ($line -match '^\s*TRACK\s+(\d+)\s+AUDIO') {
          if ($currentTrack) { $tracks += $currentTrack }
          $currentTrack = @{ Number = [int]$Matches[1]; Start = 0; Title = "" }
      } elseif ($line -match '^\s*TITLE\s+"(.+)"') {
          if ($currentTrack) { $currentTrack.Title = $Matches[1] }
      } elseif ($line -match '^\s*INDEX\s+01\s+(\d+):(\d+):(\d+)') {
          if ($currentTrack) {
              $mm = [int]$Matches[1]; $ss = [int]$Matches[2]; $ff = [int]$Matches[3]
              $currentTrack.Start = $mm * 60 + $ss + $ff / 75.0
          }
      }
  }
  if ($currentTrack) { $tracks += $currentTrack }

  Write-Host "Found $($tracks.Count) tracks"
  Write-Host ""

  for ($i = 0; $i -lt $tracks.Count; $i++) {
      $t = $tracks[$i]
      $num = '{0:D2}' -f $t.Number
      $safe = $t.Title -replace '[\\/:*?"<>|]', '_'
      $out = Join-Path $dir "$num - $safe.flac"

      $a = @('-y', '-loglevel', 'error', '-ss', "$($t.Start)")
      if ($i -lt $tracks.Count - 1) {
          $a += '-to'; $a += "$($tracks[$i + 1].Start)"
      }
      $a += '-i'; $a += "$($file.Path)"
      $a += '-c:a'; $a += 'flac'
      $a += '-c:v'; $a += 'copy'
      $a += '-map_metadata'; $a += '0'
      $a += '-metadata'; $a += "track=$num"
      $a += '-metadata'; $a += "title=$($t.Title)"
      $a += '-metadata'; $a += 'cuesheet='
      $a += $out

      & ffmpeg.exe $a 2>$null
      Write-Host "  $num - $($t.Title).flac"
  }
}

