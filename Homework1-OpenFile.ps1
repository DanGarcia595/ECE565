$filename = Read-Host "Please enter the filename"
if(Test-Path $filename){
    $fileContents = Get-Content $filename
    Write-Host $fileContents
}else {
    Write-Host "File not found"
}
[System.GC]::Collect()