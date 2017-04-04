﻿# Получаем данные за один день
$Date = (Get-Date).AddDays(-1)

# Получаем события из лога      
$Events = Get-Winevent -FilterHashTable @{LogName='ForwardedEvents'; ID=307;StartTime = $Date;}      

# Массив заданий печати
$Jobs = @()
ForEach ($Event in $Events) {            
    # Конвертируем событие XML            
    $eventXML = [xml]$Event.ToXml()
    # Создаем новый объект задания печати и заполняем поля из XML-представления события            
    $PrintJob = New-Object PsObject
    Add-Member -Force -InputObject $PrintJob -MemberType NoteProperty -Name PageCount -Value $eventXML.Event.UserData.DocumentPrinted.Param8
	Add-Member -Force -InputObject $PrintJob -MemberType NoteProperty -Name UserName -Value $eventXML.Event.UserData.DocumentPrinted.Param3
	Add-Member -Force -InputObject $PrintJob -MemberType NoteProperty -Name DocumentName -Value $eventXML.Event.UserData.DocumentPrinted.Param2
	Add-Member -Force -InputObject $PrintJob -MemberType NoteProperty -Name Size -Value $eventXML.Event.UserData.DocumentPrinted.Param7
	Add-Member -Force -InputObject $PrintJob -MemberType NoteProperty -Name Printer -Value $eventXML.Event.UserData.DocumentPrinted.Param5
    $NamePC = $eventXML.Event.UserData.DocumentPrinted.Param4
    $NamePC.Replace("\\","")
	Add-Member -Force -InputObject $PrintJob -MemberType NoteProperty -Name Computerr -Value $NamePC
    # Приводим дату из формата SystemTime к обычному представлению.
    $date = Get-Date $eventXML.Event.System.TimeCreated.SystemTime
    Add-Member -Force -InputObject $PrintJob -MemberType NoteProperty -Name Time -Value $date
    # Добавляем задание печати к массиву
    $Jobs += $PrintJob
}            

# Выводим список полученных заданий печати в CSV          
$Jobs | Export-Csv events-$(Get-Date -format yyyyMMdd).csv -NoTypeInformation -Encoding UTF8 -Delimiter ';'  

