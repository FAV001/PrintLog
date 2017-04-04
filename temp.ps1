# Получаем события из лога      
$Events = Get-Winevent -FilterHashTable @{LogName='Microsoft-Windows-PrintService/Operational'; ID=307;} 
Write-Host $Events.Count

<#$Events = Get-Winevent -FilterHashTable @{LogName = 'Microsoft-Windows-PrintService/Operational'; ID = 307; StartTime = $lasteventupdate; } 
$CountEvent = $Events.Count
#Write-Log "Количество не сохраненных событий печати -> $CountEvent" "INFO"#>