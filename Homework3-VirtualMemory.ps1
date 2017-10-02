# Author: Daniel Garcia
# Student ID: 01411723
# ECE 565 2017 HW#2 Problem 6

param (
    [Parameter(Mandatory=$false)][string]$filename = "ece565hw03.txt"
)

function main{
    param (
        [Parameter(Mandatory=$true)][string]$filename
    )
    Write-Host "Starting Virtual Memory Simulation Program"
    $table =  parsedata $filename
    $queue = New-Object System.Collections.Queue
    $hash = [hashtable]::Synchronized(@{})
    $hash.queue = $queue
    $hash.Flag = $true
    $hash.Host = $host
    $runspace1 = [runspacefactory]::CreateRunspace()
    $runspace1.Open()
    $runspace1.SessionStateProxy.SetVariable('Hash',$hash)
    $powershell1 = [powershell]::Create()
    $powershell1.Runspace = $runspace1
    $powershell1.AddScript({
        while($hash.Flag){
            $address = Get-Random -Minimum 0 -Maximum 4
            $hash.host.ui.Write("Virtual Address: $address generated | ")
            $hash.queue.Enqueue($address)
            Start-Sleep 1
        }
    }) | Out-Null
    $powershell1.BeginInvoke()

    $runspace2 = [runspacefactory]::CreateRunspace()
    $runspace2.Open()
    $runspace2.SessionStateProxy.SetVariable('Hash',$hash)
    $runspace2.SessionStateProxy.SetVariable('Table',$table)
    $powershell2 = [powershell]::Create()
    $powershell2.Runspace = $runspace2
    $powershell2.AddScript({
        while($hash.Flag){
            $virtualAddress = $hash.queue.Dequeue()
            $page = [int]($virtualAddress/2)
            $offset = $virtualAddress%2
            $validity = $table.valid[$page]
            $hash.host.ui.Write("Page: $page | Offset: $offset | Valid: $validity ")
            if($validity -eq "v"){
                $frame = [int]($table.frame[$page])
                $address = $frame * 2 + $offset
                $hash.host.ui.WriteLine("| Frame: $frame | Address: $address")
            }
            else{
                $hash.host.ui.WriteLine("| Page Fault.")
            }
            Start-Sleep 1
        }
    }) | Out-Null
    $powershell2.BeginInvoke()

    try
    {
        while($true){}
    }
    finally
    {
        $hash.Flag = $false
        write-host "Exiting Simulation"
    }
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
    foreach($line in $fileContents){
        $process = New-Object pscustomobject
        $keyValuePair = ($line -split '\s+')
        $process | Add-Member -MemberType NoteProperty -Name "frame" -Value "$($keyValuePair[0])"
        $process | Add-Member -MemberType NoteProperty -Name "valid" -Value "$($keyValuePair[1])"
        $processes += $process
    }
    return $processes
}

main $filename