# Author: Daniel Garcia
# Student ID: 01411723
# ECE 565 2017 HW#2 Problem 6

param (
    [Parameter(Mandatory=$false)][string]$filename = "ece565hw02.txt"
)
function main{
    param (
        [Parameter(Mandatory=$true)][string]$filename
    )
    Write-Host "Starting Content Switching Simulation Program"
    $CPUQueue =  parsedata $filename
    firstComeFirstServe $CPUQueue
}
function firstComeFirstServe{
    param (
        [Parameter(Mandatory=$true)][pscustomobject[]]$CPUQueue
    )
    $CPUTime = 0
    foreach($process in $CPUQueue){
        if("Blocked" -ne $process.State){
            Write-Host "Loading CPU with PID $($process.PID)"
            $timeRemaining = [int]$process.CPU
            while($timeRemaining -gt 0){
                Write-Host "Running... time remaining: $timeRemaining"
                $timeRemaining--
                $CPUTime++
            }
            Write-Host "Process $($process.PID) Complete"
            Write-Host "CPU Time: $CPUTime"
        }else{
            Write-Host "Process $($process.PID) is blocked and will not be executed"
        }
    }
    Write-Host "No more processes in queue... Exiting"
}
function parsedata{
    param (
        [Parameter(Mandatory=$true)][string]$filename
    )
    
    if(Test-Path $filename){
        $fileContents = Get-Content $filename
    }else {
        return $null
    }
    $processes = @()
    $process = New-Object pscustomobject
    foreach($line in $fileContents){
        if($line -eq ''){
            $processes += $process
            $process = New-Object pscustomobject
        }else{
            $keyValuePair = ($line -split ':\s+')
            $process | Add-Member -MemberType NoteProperty -Name "$($keyValuePair[0])" -Value "$($keyValuePair[1])"
        }
    }
    return $processes
}

main $filename