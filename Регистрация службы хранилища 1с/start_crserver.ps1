[CmdletBinding()]
param (
    [Parameter(Mandatory)]
    [string] $version,
    [Parameter(Mandatory)]
    [string] $repo,
    [Parameter(Mandatory)]
    [string] $usr,
    [Parameter(Mandatory)]
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

$command = "C:\Program files\1cv8\$version\bin\crserver.exe" 

if(-not (Get-Item $command))
{
    Write-Error "Хранилище не установлено($command)"
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
    Write-Error "Не удалось создать службу $service_name"
}else{
    Start-Process $command -ArgumentList "-start" -NoNewWindow -Wait  
    Write-Host "Служба хранилища $service_name запущена"
}