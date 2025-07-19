# === CONFIG ===
$scriptDir      = Split-Path -Parent $MyInvocation.MyCommand.Definition
$headerPath     = Join-Path $scriptDir "code.h"
$versionPath    = Join-Path $scriptDir "codeh.version"
$metaPath       = Join-Path $scriptDir "code.meta.json"

$remoteHeaderURL  = "https://raw.githubusercontent.com/MoboladeJOladele/Public/main/CODE_H/code.h"
$remoteVersionURL = "https://raw.githubusercontent.com/MoboladeJOladele/Public/main/CODE_H/codeh.version"

# === Fetch remote version
try {
    $remoteVersion = Invoke-RestMethod -Uri $remoteVersionURL -UseBasicParsing
} catch {
    exit 0
}

# === Read local version
$localVersion = if (Test-Path $versionPath) {
    Get-Content $versionPath -Raw
} else {
    "none"
}

# === Only proceed if new version is available
if ($remoteVersion -ne $localVersion) {
    try {
        # === Download new code.h
        Invoke-WebRequest -Uri $remoteHeaderURL -OutFile $headerPath -UseBasicParsing

        # === Update local version file
        Set-Content -Path $versionPath -Value $remoteVersion

        # === Update meta file version field
        if (Test-Path $metaPath) {
            $meta = Get-Content $metaPath | ConvertFrom-Json
            $meta.version = $remoteVersion
            $meta | ConvertTo-Json -Depth 10 | Set-Content $metaPath

            # === Update injected paths
            foreach ($path in $meta.injected_paths) {
                try {
                    Copy-Item -Path $headerPath -Destination (Join-Path $path "code.h") -Force
                } catch {
                    Write-Warning "Failed to update code.h in $path"
                }
            }

            # === Update WSL if applicable
            if ($meta.sub_os -eq "WSL" -and $meta.wsl_paths.Count -gt 0) {
                if (Test-Path "$env:windir\System32\wsl.exe") {
                    $HeaderFileFull = (Resolve-Path $headerPath).Path
                    $headerWSL = wsl wslpath -a -u "`"$HeaderFileFull`""
                    $headerWSL = $headerWSL.Trim()

                    $copySuccess = $true
                    try {
                        wsl bash -c "sudo cp '$headerWSL' '/usr/local/include/code.h'"
                    } catch {
                        $copySuccess = $false
                    }

                    if (-not $copySuccess) {
                        try {
                            Get-Content -Raw -Encoding Byte "$HeaderFileFull" |
                                wsl bash -c "cat | sudo tee /usr/local/include/code.h > /dev/null"
                        } catch {
                            Write-Warning "Failed fallback copy to WSL"
                        }
                    }
                }
            }
        }
    } catch {
        exit 0
    }
}
