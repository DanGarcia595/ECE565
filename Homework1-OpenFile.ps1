# Author: Daniel Garcia
# Student ID: 10411723
# ECE 565 2017 HW#1 Problem 6

$filename = Read-Host "Please enter the filename"
if(Test-Path $filename){
    $fileContents = Get-Content $filename
    Write-Host $fileContents
}else {
    Write-Host "File not found"
}
[System.GC]::Collect()  