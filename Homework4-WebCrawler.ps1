function main{
    param (
        [Parameter(Mandatory=$false)][string]$address = "http://www.faculty.umassd.edu/hong.liu/ece565.html"
    )
    mirrorWebPage $address
}

function mirrorWebPage{
    param (
        [Parameter(Mandatory=$true)][string]$address,
        [Parameter(Mandatory=$false)][string]$baseURL = ""
    )
    Write-Host "Getting $address"
    if($baseURL -eq ""){
        $folderIndex = $address.LastIndexOf("/")
        if($address.EndsWith("/")){
            $address = $address.Remove($folderIndex)
            $folderIndex = $address.LastIndexOf("/")
            $address += "/"
        }
        $baseURL = $address.Substring(0,$folderIndex)
    }
    $path = $address -replace $baseURL,""
    $path = ".$path"
    if($path.EndsWith("/")){
        New-Item $path -ItemType Directory -Force
    }
    else{
        New-Item $path -Force
    }
    $page = Invoke-WebRequest $address
    $page.RawContent | Out-File $path
    if($page.Links.Count -gt 0){
        foreach($link in $page.Links){
            if($link.href -ne $address){
                if($link.href -notmatch "http" -and $link.href  -notmatch "#" -and $link.href  -notmatch '\?' -and $link.href -notmatch 'mailto'){
                    mirrorWebPage "$baseURL/$($link.href)" $baseURL
                }
            }
        }
    }
}

main