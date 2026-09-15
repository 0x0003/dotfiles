# sets a given image as desktop wallpaper via IDesktopWallpaper COM API;
# provides an interactive `set-wallpaper` function;
# and also works as a direct call (from e.g. mpv):
# powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File ".../set-wallpaper.ps1" "<path>"

if (-not ('WallpaperSetter' -as [type])) {
    Add-Type -TypeDefinition @'
using System;
using System.Runtime.InteropServices;

[ComImport]
[Guid("B92B56A9-8B55-4E14-9A89-0199BBB6F93B")]
[InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
interface IDesktopWallpaper
{
    void SetWallpaper([MarshalAs(UnmanagedType.LPWStr)] string monitorID, [MarshalAs(UnmanagedType.LPWStr)] string wallpaper);
}

public static class WallpaperSetter
{
    public static void Set(string path)
    {
        Type type = Type.GetTypeFromCLSID(new Guid("C2CF3110-460E-4fc1-B9D0-8A1C0C9CC4BD"));
        IDesktopWallpaper dw = (IDesktopWallpaper)Activator.CreateInstance(type);
        dw.SetWallpaper(null, path);
    }
}
'@
}

function set-wallpaper {
    param(
        [Parameter(Mandatory = $true)]
        [string]$Path
    )

    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) {
        throw "Image file not found: $Path"
    }

    $Path = (Resolve-Path -LiteralPath $Path).Path

    [WallpaperSetter]::Set($Path)
    Write-Output "Wallpaper set to: $Path"
}

if ($MyInvocation.InvocationName -ne '.') {
    # invoked directly: run it now
    if (-not $args[0]) {
        throw "Usage: powershell.exe -File set-wallpaper.ps1 <path-to-image>"
    }
    set-wallpaper -Path $args[0]
}

