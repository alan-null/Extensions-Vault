# Define the paths
$dbPath = Join-Path $PSScriptRoot "db"
$outPath = Join-Path $PSScriptRoot "out"
$tempPath = Join-Path $PSScriptRoot "temp"

Add-Type -AssemblyName System.IO.Compression.FileSystem

function Get-Version ($file) {
    [string]$name = $file.BaseName

    if ($name -match '.*?(\d+)[._](\d+)[._](\d+).*') {
        $major = $matches[1]
        $minor = $matches[2]
        $patch = $matches[3]

        [System.Version]::new($major, $minor, $patch)
    }
    else {
        Write-Error "No valid version found in the filename."
    }
}

function Expand-CrxOrZip {
    param(
        [string]$SourcePath,
        [string]$DestinationPath
    )

    $bytes = [System.IO.File]::ReadAllBytes($SourcePath)

    # CRX files start with magic bytes: Cr24 (0x43 0x72 0x32 0x34)
    if ($bytes.Length -gt 12 -and $bytes[0] -eq 0x43 -and $bytes[1] -eq 0x72 -and $bytes[2] -eq 0x32 -and $bytes[3] -eq 0x34) {
        $version = [System.BitConverter]::ToUInt32($bytes, 4)

        $zipStart = switch ($version) {
            2 {
                $pubKeyLen = [System.BitConverter]::ToUInt32($bytes, 8)
                $sigLen    = [System.BitConverter]::ToUInt32($bytes, 12)
                16 + $pubKeyLen + $sigLen
            }
            3 {
                $headerLen = [System.BitConverter]::ToUInt32($bytes, 8)
                12 + $headerLen
            }
            default { throw "Unsupported CRX version: $version" }
        }

        $zipBytes = $bytes[$zipStart..($bytes.Length - 1)]
        $tempZip  = [System.IO.Path]::Combine([System.IO.Path]::GetTempPath(), "$([System.Guid]::NewGuid()).zip")
        [System.IO.File]::WriteAllBytes($tempZip, $zipBytes)

        try {
            [System.IO.Compression.ZipFile]::ExtractToDirectory($tempZip, $DestinationPath)
        }
        finally {
            Remove-Item $tempZip -Force -ErrorAction SilentlyContinue
        }
    }
    else {
        [System.IO.Compression.ZipFile]::ExtractToDirectory($SourcePath, $DestinationPath)
    }
}

Get-ChildItem -Path $dbPath -Directory | ForEach-Object {
    $extensionFolder = $_

    $latestCrx = Get-ChildItem -Path $extensionFolder.FullName | ? { $_.Extension -in '.crx', '.zip' } | Sort-Object { Get-Version $_ } -Descending | Select-Object -First 1
    if ($latestCrx) {
        Write-Host "Extracting $($latestCrx.Name)" -ForegroundColor Green
        $tempExtractFolder = Join-Path $tempPath $latestCrx.BaseName
        Expand-CrxOrZip -SourcePath $latestCrx.FullName -DestinationPath $tempExtractFolder

        $manifestPath = Join-Path $tempExtractFolder "manifest.json"
        $manifest = Get-Content $manifestPath | ConvertFrom-Json
        $extensionName = $manifest.name
        $manifest.name = "🛡️ $extensionName"
        $manifest | ConvertTo-Json -Depth 10 | Set-Content $manifestPath

        Write-Host "`tDeploying $($latestCrx.Name) as" -ForegroundColor DarkGray -NoNewline
        Write-Host "'$extensionName'" -ForegroundColor Yellow

        $outputFolder = Join-Path $outPath $extensionName
        if (Test-Path $outputFolder) {
            Write-Host "`tRemoving existing folder" -ForegroundColor DarkGray
            Remove-Item -Path $outputFolder -Recurse -Force
        }

        Write-Host "`tMoving files to $outputFolder" -ForegroundColor DarkGray
        New-Item -ItemType Directory -Path $outputFolder | Out-Null
        Move-Item -Path (Join-Path $tempExtractFolder "*") -Destination $outputFolder
        Remove-Item -Path $tempExtractFolder -Recurse -Force
    }
}
Remove-Item -Path $tempPath -Recurse -Force