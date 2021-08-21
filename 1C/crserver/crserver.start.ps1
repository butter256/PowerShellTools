[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [Alias('v')]
    [string] $ver,
    [Parameter(Mandatory)]
    [Alias('r')]
    [string] $repo,
    [Parameter(Mandatory)]
    [Alias('u')]
    [string] $usr,
    [Parameter(Mandatory)]
    [Alias('p')]
    [string] $pas
)

function Get-ServiceForName {
    [CmdletBinding()]
    param (
    [Parameter(Mandatory)]    
    [string] $name
    )
    
    try {
        $service = Get-Service -Name $name    
    }
    catch {
        $service = $null   
    }

    $service
}

$command = "C:\Program files\1cv8\$ver\bin\crserver.exe" 

if(-not (Get-Item $command))
{
    "$command not installed" | ConvertTo-Windows1251 | Write-Error
    return
}

$service_name = "1C:Enterprise 8.3 Configuration Repository Server"

$service = Get-ServiceForName -Name $service_name

if ($null -eq $service){
    Start-Process $command -ArgumentList "-instsrvc -d $repo -usr .\$usr -pwd $pas" -NoNewWindow -Wait
}else{
    Start-Process $command -ArgumentList "-rmsrvc" -NoNewWindow -Wait
    Start-Process $command -ArgumentList "-instsrvc -d $repo -usr .\$usr -pwd $pas" -NoNewWindow -Wait
}

Start-Sleep -Seconds 1

if ($null -eq $service){
    "Failed to create a service $service_name" | Write-Error 
}else{
    Start-Process $command -ArgumentList "-start" -NoNewWindow -Wait  
    "The service $service_name has been started" | Write-Host
}