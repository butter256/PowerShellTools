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

[Console]::OutputEncoding = [System.Text.Encoding]::GetEncoding("UTF-8")

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

function ConvertTo-Windows1251 (){
    Begin{
        $encFrom = [System.Text.Encoding]::GetEncoding("UTF-8")
        $encTo = [System.Text.Encoding]::GetEncoding("Windows-1251")
    }
    Process{
        $bytes = $encTo.GetBytes($_)
        $bytes = [System.Text.Encoding]::Convert($encFrom, $encTo, $bytes)
        $encTo.GetString($bytes)
    }
}

$command = "C:\Program files\1cv8\$ver\bin\crserver.exe" 

if(-not (Get-Item $command))
{
    "Хранилище конфигураций не установлено($command)" | ConvertTo-Windows1251 | Write-Error
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
    "Не удалось создать службу хранилища конфигураций $service_name" | ConvertTo-Windows1251 | Write-Error 
}else{
    Start-Process $command -ArgumentList "-start" -NoNewWindow -Wait  
    "Служба хранилища конфигураций $service_name успешно создана" | ConvertTo-Windows1251 | Write-Host
}