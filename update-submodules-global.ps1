Set-Location ..

git submodule update --init --recursive --remote

$folders = Get-ChildItem -Directory
foreach ($folder in $folders) {
    $targetPath = Join-Path $folder.FullName "shared-docs\docs"
    if (Test-Path $targetPath) {
        Write-Host "Running git submodules update in $($folder.Name)..." -ForegroundColor Green
        Push-Location $targetPath
        git submodule update --init --recursive --remote
        Pop-Location
    }
    else {
        Write-Host "Skipping $($folder.Name), because shared-docs folder wasn't found" -ForegroundColor Yellow
    }
}
