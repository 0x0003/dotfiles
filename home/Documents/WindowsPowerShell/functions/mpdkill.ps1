# graceful shutdown via mpd protocol
function mpdkill() {
    param(
        [string] $mpdHost = "127.0.0.1",
        [int] $mpdPort = 6600
    )
    $client = New-Object System.Net.Sockets.TcpClient($mpdHost, $mpdPort)
    $stream = $client.GetStream()
    $writer = New-Object System.IO.StreamWriter($stream)
    $writer.AutoFlush = $true
    $writer.WriteLine("kill")
    Start-Sleep -Milliseconds 100
    $client.Close()
}
