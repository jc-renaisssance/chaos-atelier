param(
    [string]$GodotPath = "C:\Users\Jonathan\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$BuildDir = Join-Path $ProjectRoot "build\windows"
$BuildExe = Join-Path $BuildDir "Wombaste.exe"
$ConsoleExe = Join-Path $BuildDir "Wombaste.console.exe"
$ExportAppData = Join-Path $ProjectRoot ".godot\export-smoke-appdata"
$PreviousAppData = $env:APPDATA

if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw "Godot executable not found: $GodotPath"
}

New-Item -ItemType Directory -Force -Path $BuildDir | Out-Null
New-Item -ItemType Directory -Force -Path $ExportAppData | Out-Null

try {
    $ExportOutput = & $GodotPath --headless --path $ProjectRoot --export-debug "Windows Desktop" $BuildExe 2>&1
    $ExportExit = $LASTEXITCODE
    $ExportOutput | Write-Output
    if ($ExportExit -ne 0 -or ($ExportOutput -join "`n") -match "(SCRIPT ERROR|ERROR:)") {
        exit 1
    }
    if (-not (Test-Path -LiteralPath $ConsoleExe -PathType Leaf)) {
        throw "Debug export did not produce its console wrapper: $ConsoleExe"
    }

    # Boot the exported product without touching the player's real user:// save.
    $env:APPDATA = $ExportAppData
    $BootOutput = & $ConsoleExe --headless --quit-after 120 2>&1
    $BootExit = $LASTEXITCODE
    $BootOutput | Write-Output
    if ($BootExit -ne 0 -or ($BootOutput -join "`n") -match "(SCRIPT ERROR|ERROR:)") {
        exit 1
    }
    exit 0
}
finally {
    $env:APPDATA = $PreviousAppData
}
