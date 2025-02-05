# Define the paths
$dbPath = "$PSScriptRoot\db"
$outPath = "$PSScriptRoot\out"
$tempPath = "$PSScriptRoot\temp"
$toolsPath = "$PSScriptRoot\tools"
$toolName = "7-Zip.CommandLine"

function Get-Version ($file) {
    [version] ($file.BaseName -replace '.*?(\d+\.\d+\.\d+).*', '$1')
}

function Install-Tooling {
    if (!(Test-Path "$toolsPath\$toolName\*\tools\7za.exe")) {
        Write-Host "Installing $toolName" -ForegroundColor Green
        nuget install $toolName -OutputDirectory "$toolsPath\$toolName" -source "https://api.nuget.org/v3/index.json"
    }
    $7zip = Get-Item -Path "$toolsPath\$toolName\*\tools\7za.exe"
    Set-Alias 7zip $7zip.FullName -Scope Script
}

Install-Tooling

Get-ChildItem -Path $dbPath -Directory | ForEach-Object {
    $extensionFolder = $_

    $latestCrx = Get-ChildItem -Path $extensionFolder.FullName  | ? { $_.Extension -in '.crx', '.zip' } | Sort-Object { Get-Version $_ } -Descending | Select-Object -First 1
    if ($latestCrx) {
        Write-Host "Extracting $($latestCrx.Name)" -ForegroundColor Green
        $tempExtractFolder = "$tempPath\$($latestCrx.BaseName)"
        7zip x "$($latestCrx.FullName)" -o"$tempExtractFolder" -aoa >> $null

        $manifest = Get-Content "$tempExtractFolder\manifest.json" | ConvertFrom-Json
        $extensionName = $manifest.name

        Write-Host "`tDeploying $($latestCrx.Name) as" -ForegroundColor DarkGray -NoNewline
        Write-Host "'$extensionName'" -ForegroundColor Yellow

        $outputFolder = "$outPath\$extensionName"
        if (Test-Path $outputFolder) {
            Write-Host "`tRemoving existing folder" -ForegroundColor DarkGray
            Remove-Item -Path $outputFolder -Recurse -Force
        }

        write-host "`tMoving files to $outputFolder" -ForegroundColor DarkGray
        mkdir $outputFolder | Out-Null
        Move-Item -Path "$tempExtractFolder\*" -Destination $outputFolder
        Remove-Item -Path $tempExtractFolder -Recurse -Force
    }
}
Remove-Item -Path $tempPath -Recurse -Force