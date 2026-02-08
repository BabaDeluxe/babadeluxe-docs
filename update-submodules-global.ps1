Set-Location ..

git submodule update --init --recursive --remote

$folders = Get-ChildItem -Directory -Force
foreach ($folder in $folders) {
    $gitmodulesPath = Join-Path $folder.FullName ".gitmodules"
    
    if (Test-Path $gitmodulesPath) {
        Write-Host "Running git submodules update in $($folder.Name)..." -ForegroundColor Green
        Push-Location $folder.FullName
        git submodule update --init --recursive --remote
        Pop-Location
    }
    else {
        Write-Host "Skipping $($folder.Name), no .gitmodules found" -ForegroundColor Yellow
    }
}
