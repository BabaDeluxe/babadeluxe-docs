$currentDirName = Split-Path (Get-Location) -Leaf
if ($currentDirName -ne 'babadeluxe-docs') {
    Write-Host "Not in babadeluxe-docs, skipping git submodule updates." -ForegroundColor Yellow
    return
}

Set-Location ..

git submodule update --init --recursive --remote

$folders = Get-ChildItem -Directory -Force
$jobs = @()

foreach ($folder in $folders) {
    $jobs += Start-ThreadJob -Name $folder.Name -ScriptBlock {
        param($folderPath, $folderName)

        $gitmodulesPath = Join-Path $folderPath ".gitmodules"

        if (Test-Path $gitmodulesPath) {
            Write-Host "Running git submodules update in $folderName..." -ForegroundColor Green
            Push-Location $folderPath
            git submodule update --init --recursive --remote
            Pop-Location
        }
        else {
            Write-Host "Skipping $folderName, no .gitmodules found" -ForegroundColor Yellow
        }
    } -ArgumentList $folder.FullName, $folder.Name
}
$jobs | Wait-Job | Receive-Job
Remove-Job $jobs
