# curl -> scoop's curl.exe
Remove-Item alias:\curl
New-Alias -Name curl -Value "C:\users\$env:USERNAME\scoop\apps\curl\current\bin\curl.exe"

# start -> open
function open() {
    param([string] $arg)
    start $arg
}

function GalleryDlProxyInput() {
[alias("gdlkpi")]
    param([string] $file)
    gallery-dl.exe --proxy socks5://127.0.0.1:2080 -i $file
}

# scoop
function sus { scoop status }
function sup() {
    param([string] $x)
    scoop update $x
}
function sups { sup; sus }
function sca { scoop cache show }
function scar() {
    param([string] $x)
    scoop cache rm $x
}
function scl() {
    param([string] $x)
    scoop cleanup $x
}
function sgc {
    $repos = @(
      "C:\users\$env:USERNAME\scoop\buckets\main",
      "C:\users\$env:USERNAME\scoop\buckets\extras"
      "C:\users\$env:USERNAME\scoop\buckets\sniffer"
    )
    $jobs = foreach ($repo in $repos) {
        Start-Job -ScriptBlock {
            param($path)
            if (Test-Path $path) {
                Write-Host "Running git gc in $path"
                Set-Location $path
                git gc
            }
        } -ArgumentList $repo
    }
    $jobs | Wait-Job | Receive-Job
}

# chezmoi
function cmin { chezmoi init @args }
function cmad { chezmoi add @args }
function cmed { chezmoi edit --apply @args }
function cmre { chezmoi re-add @args }
function cmdr { chezmoi apply --dry-run -v }
function cmst { chezmoi status }
function cmdi { chezmoi diff @args }
function cmap { chezmoi apply -v }
function cmup { chezmoi update }
function cmfo { chezmoi forget @args }
function cmrm { chezmoi remove @args }
function cmgc { Push-Location "$env:USERPROFILE\.local\share\chezmoi"; git gc; Pop-Location }
function cmcd { Set-Location "$env:USERPROFILE\.local\share\chezmoi"; git status; echo " "; chezmoi status }

# Cloudflare WARP
function warpmasque() {
    usque socks -b 127.0.0.1 -p 8086 -s rateyourmusic.com -P 443 --always-reconnect -d 1.1.1.1 -d 1.0.0.1 -d 2606:4700:4700::1111 -d 2606:4700:4700::1001
}
# -d 9.9.9.9 -d 149.112.112.112 -d 2620:fe::fe -d 2620:fe::9
# -d 1.1.1.1 -d 1.0.0.1 -d 2606:4700:4700::1111 -d 2606:4700:4700::1001

# wireproxy-awg
function warpwire() {
  param([string] $conf)
    wireproxy -c C:\Users\$env:USERNAME\scoop\persist\wireproxy-awg\config\$conf
}

# koboldcpp
# 32768
function koboldgemma() {
    koboldcpp.exe --model "C:\Software\ai\llm\gemma-4-12b-it-UD-Q5_K_XL.gguf" --mmproj "C:\Software\ai\llm\mmproj-F16.gguf" --jinja --quiet --skiplauncher --usecublas --gpulayers -1 --flash-attn --contextsize 24576
 }

function koboldqwen() {
    koboldcpp.exe --model "C:\Software\ai\llm\Qwen3.6-27B-Q3_K_M.gguf" --quiet --skiplauncher --usecublas --gpulayers 40 --flash-attn --contextsize 100000
 }

# ffmpeg
# generate a spectrogram
function spec() {
    param([string] $i)
    ffmpeg -i $i -lavfi showspectrumpic=s=2000x1000:mode=separate $i'.png'
}

# batch convert flac to mp3-320
function flac2mp3() {
    dir *.flac | foreach {ffmpeg -i $_.FullName -ab 320k -map_metadata 0 -id3v2_version 3 $_.FullName.Replace('flac', 'mp3')}
}

# batch convert wav to mp3-320
function wav2mp3() {
    dir *.wav | foreach {ffmpeg -i $_.FullName -ab 320k -map_metadata 0 -id3v2_version 3 $_.FullName.Replace('wav', 'mp3')}
}

# batch convert mov to mp4
function mov2mp4() {
    dir *.mov | foreach {ffmpeg -i $_.FullName -q:v 0 $_.FullName.Replace('mov', 'mp4')}
}

# batch convert h.264 to h.265
function h264toh265() {
    dir *.mp4 | foreach {ffmpeg -i $_.FullName -vcodec libx265 -crf 28 ('h265_' + $_.Name)}
}

