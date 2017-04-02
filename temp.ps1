# Получаем события из лога      
$Events = Get-Winevent -FilterHashTable @{LogName='Microsoft-Windows-PrintService/Operational'; ID=307;} 
Write-Host $Events.Count
