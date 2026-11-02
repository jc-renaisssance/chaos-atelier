param(
    [string]$GodotPath = "C:\Users\Jonathan\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
)

$ErrorActionPreference = "Stop"
$ProjectRoot = Split-Path -Parent $PSScriptRoot
$SmokeAppData = Join-Path $ProjectRoot ".godot\smoke-appdata"
$PreviousAppData = $env:APPDATA

if (-not (Test-Path -LiteralPath $GodotPath -PathType Leaf)) {
    throw "Godot executable not found: $GodotPath"
}

New-Item -ItemType Directory -Force -Path $SmokeAppData | Out-Null

try {
    # Keep smoke saves isolated from the player's real user:// profile and run.
    $env:APPDATA = $SmokeAppData

    $BootOutput = & $GodotPath --headless --path $ProjectRoot --quit-after 120 2>&1
    $BootExit = $LASTEXITCODE
    $BootOutput | Write-Output
    if ($BootExit -ne 0 -or ($BootOutput -join "`n") -match "(SCRIPT ERROR|ERROR:)") {
        exit 1
    }

    $SmokeOutput = & $GodotPath --headless --path $ProjectRoot --scene "res://tests/m2_smoke.tscn" 2>&1
    $SmokeExit = $LASTEXITCODE
    $SmokeOutput | Write-Output
    if ($SmokeExit -ne 0 -or ($SmokeOutput -join "`n") -match "(SCRIPT ERROR|ERROR:)") {
        exit 1
    }
    exit 0
}
finally {
    $env:APPDATA = $PreviousAppData
}
