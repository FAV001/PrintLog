#Ini section
#задаем настройки для соеднения с SQL
$sql_server = "10.193.1.161"
$sql_instance = "sqlexpress"
$user = "login_pel"
$password = "EQLwaZRj5H"
$base = "PrintLog" 

#INI секция
#настройки логирования
$logFile = "$(Get-Content Env:TEMP)\plagent.log" # имя лог файла
$logSize = 250kb    #максимальный размер файла лога, если больше пересоздаем
$logLevel = "DEBUG" # ("DEBUG","INFO","WARN","ERROR","FATAL")
$logCount = 2   #Количетсво хранимых логов при ротации

#INI End

function Write-Log-Line ($line) {
    Add-Content $logFile -Value $Line
    Write-Host $Line
}

Function Write-Log {
    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $True)]
        [string]
        $Message,
    
        [Parameter(Mandatory = $False)]
        [String]
        $Level = "DEBUG"
    )

    $Null = @(Reset-Log -fileName $logFile -filesize $logSize -logcount $logCount)
    $levels = ("DEBUG", "INFO", "WARN", "ERROR", "FATAL")
    $logLevelPos = [array]::IndexOf($levels, $logLevel)
    $levelPos = [array]::IndexOf($levels, $Level)
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss:fff")

    if ($logLevelPos -lt 0) {
        Write-Log-Line "$Stamp ERROR Wrong logLevel configuration [$logLevel]"
    }
    
    if ($levelPos -lt 0) {
        Write-Log-Line "$Stamp ERROR Wrong log level parameter [$Level]"
    }

    # if level parameter is wrong or configuration is wrong I still want to see the 
    # message in log
    if ($levelPos -lt $logLevelPos -and $levelPos -ge 0 -and $logLevelPos -ge 0) {
        return
    }

    $Line = "$Stamp $Level $Message"
    Write-Log-Line $Line
}

function Reset-Log 
{ 
    #function checks to see if file in question is larger than the paramater specified if it is it will roll a log and delete the oldes log if there are more than x logs. 
    param([string]$fileName, [int64]$filesize = 1mb , [int] $logcount = 5) 
     
    $logRollStatus = $true 
    if(test-path $filename) 
    { 
        $file = Get-ChildItem $filename 
        if((($file).length) -ige $filesize) #this starts the log roll 
        { 
            $fileDir = $file.Directory 
            $fn = $file.name #this gets the name of the file we started with 
            $files = Get-ChildItem $filedir | ?{$_.name -like "$fn*"} | Sort-Object lastwritetime 
            $filefullname = $file.fullname #this gets the fullname of the file we started with 
            #$logcount +=1 #add one to the count as the base file is one more than the count 
            for ($i = ($files.count); $i -gt 0; $i--) 
            {  
                #[int]$fileNumber = ($f).name.Trim($file.name) #gets the current number of the file we are on 
                $files = Get-ChildItem $filedir | ?{$_.name -like "$fn*"} | Sort-Object lastwritetime 
                $operatingFile = $files | ?{($_.name).trim($fn) -eq $i} 
                if ($operatingfile) 
                 {$operatingFilenumber = ($files | ?{($_.name).trim($fn) -eq $i}).name.trim($fn)} 
                else 
                {$operatingFilenumber = $null} 
 
                if(($operatingFilenumber -eq $null) -and ($i -ne 1) -and ($i -lt $logcount)) 
                { 
                    $operatingFilenumber = $i 
                    $newfilename = "$filefullname.$operatingFilenumber" 
                    $operatingFile = $files | Where-Object{($_.name).trim($fn) -eq ($i-1)} 
                    write-host "moving to $newfilename" 
                    move-item ($operatingFile.FullName) -Destination $newfilename -Force 
                } 
                elseif($i -ge $logcount) 
                { 
                    if($operatingFilenumber -eq $null) 
                    {  
                        $operatingFilenumber = $i - 1 
                        $operatingFile = $files | ?{($_.name).trim($fn) -eq $operatingFilenumber} 
                        
                    } 
                    write-host "deleting " ($operatingFile.FullName) 
                    remove-item ($operatingFile.FullName) -Force 
                } 
                elseif($i -eq 1) 
                { 
                    $operatingFilenumber = 1 
                    $newfilename = "$filefullname.$operatingFilenumber" 
                    write-host "moving to $newfilename" 
                    move-item $filefullname -Destination $newfilename -Force 
                } 
                else 
                { 
                    $operatingFilenumber = $i +1  
                    $newfilename = "$filefullname.$operatingFilenumber" 
                    $operatingFile = $files | ?{($_.name).trim($fn) -eq ($i-1)} 
                    write-host "moving to $newfilename" 
                    move-item ($operatingFile.FullName) -Destination $newfilename -Force    
                } 
                     
            } 
 
                     
          } 
         else 
         { $logRollStatus = $false} 
    } 
    else 
    { 
        $logrollStatus = $false 
    } 
    $LogRollStatus 
} 

function Get-DatabaseData {
    [CmdletBinding()]
    param (
        [string]$connectionString,
        [string]$query,
        [switch]$isSQLServer
    )
    if ($isSQLServer) {
        Write-Verbose 'in SQL Server mode'
        $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    }
    else {
        Write-Verbose 'in OleDB mode'
        $connection = New-Object -TypeName System.Data.OleDb.OleDbConnection
    }
    $connection.ConnectionString = $connectionString
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    if ($isSQLServer) {
        $adapter = New-Object -TypeName System.Data.SqlClient.SqlDataAdapter $command
    }
    else {
        $adapter = New-Object -TypeName System.Data.OleDb.OleDbDataAdapter $command
    }
    $dataset = New-Object -TypeName System.Data.DataSet
    $adapter.Fill($dataset)
    $dataset.Tables[0]
}

function Invoke-DatabaseQuery {
    [CmdletBinding()]
    param (
        [string]$connectionString,
        [string]$query,
        [switch]$isSQLServer
    )
    if ($isSQLServer) {
        Write-Verbose 'in SQL Server mode'
        $connection = New-Object -TypeName System.Data.SqlClient.SqlConnection
    }
    else {
        Write-Verbose 'in OleDB mode'
        $connection = New-Object -TypeName System.Data.OleDb.OleDbConnection
    }
    $connection.ConnectionString = $connectionString
    $command = $connection.CreateCommand()
    $command.CommandText = $query
    $connection.Open()
    $command.ExecuteNonQuery()
    $connection.close()
}

function Invoke-UpdateLastConection {
    #Update last connect
    [CmdletBinding()]
    param (
        [string]$ComputerName
    )
    try {
        $sqlQuery = "exec dbo.update_pc_last_connect '$ComputerName';"
        Get-DatabaseData -connectionString $ConnectionSQLString -query $sqlQuery -isSQLServer 
    }
    catch {
        Write-Log "Что-то пошло не так $_.FullyQualifiedErrorId" "ERROR"        
    }
}

function Invoke-UpdateLastEvent {
    #Update last event
    [CmdletBinding()]
    param (
        [string]$ComputerName,
        [string]$date
    )
    try {
        $sqlQuery = "exec dbo.update_pc_last_event '$ComputerName', '$date';"
        Get-DatabaseData -connectionString $ConnectionSQLString -query $sqlQuery -isSQLServer 
    }
    catch {
        Write-Log "Что-то пошло не так $_.FullyQualifiedErrorId" "ERROR"        
    }
}

function Invoke-Event {    
    #Insert Event to DB
    [CmdletBinding()]
    param (
        [string]$sID,
        [int]$computer,
	    [string]$user,
	    [int]$pages_count,
	    [string]$document_name,
	    [int]$size,
	    [string]$printer_name,
	    [string]$datetimeprint
    )
    try {
        $userId = Get-UserID -username $user
        $sqlQuery = "exec dbo.add_event '$sID','$computer','$userId','$pages_count','$document_name','$size','$printer_name','$datetimeprint';"
        Get-DatabaseData -connectionString $ConnectionSQLString -query $sqlQuery -isSQLServer 
        Write-Log "Event добавлен успешно -> $sID" "INFO"        
    }
    catch {
        Write-Log "Event не добавлен" "ERROR"
    } 
}

function Get-UpdateLastEvent {
    [CmdletBinding()]
    param (
        [string]$ComputerName
    )
    try {
        $sqlQuery = "exec dbo.get_last_event_update '$ComputerName';"
        $result = (Get-DatabaseData -connectionString $ConnectionSQLString -query $sqlQuery -isSQLServer)[1][0]
        Write-Log "получили Last Update Event - $result" "INFO"
        return $result
    }
    catch {
        Write-Log "Что-то пошло не так $_.FullyQualifiedErrorId" "ERROR"        
    }
}

function Get-UpdateLastConnect {
    [CmdletBinding()]
	param (
		[string]$ComputerName
	)
    try {
        $sqlQuery = "exec dbo.get_last_connect '$ComputerName';"
        $result = (Get-DatabaseData -connectionString $ConnectionSQLString -query $sqlQuery -isSQLServer)[1][0]   
        Write-Log "получили Last Connection - $result" "INFO"
        return $result
    }
    catch {
        Write-Log "Что-то пошло не так $_.FullyQualifiedErrorId" "ERROR"        
    }
}

function Get-UserID {
    [CmdletBinding()]
	param (
		[string]$username
	)
    try {
        $sqlQuery = "exec dbo.get_user_id '$username';"
        $result = (Get-DatabaseData -connectionString $ConnectionSQLString -query $sqlQuery -isSQLServer)[1][0]
        Write-Log "получили UserID - $result" "INFO"
        return $result
    }
    catch {
        Write-Log "Что-то пошло не так $_.FullyQualifiedErrorId" "ERROR"        
    }
}

# Основной алгоритм
Write-Log "======================   Начинаем работу  ==========================" "INFO"
try {
    Test-Connection -ComputerName $sql_server -ErrorAction Stop | Out-Null
    Write-Log "SQL Сервер $sql_server доступен" "INFO"
    if ($sql_instance -ne "") {
        $ConnectionSQLString = "Data Source= $sql_server\$sql_instance;Initial Catalog=$base;User ID=$user;Password=$password;"
        #        $ConnectionSQLString = "Provider=SQLOLEDB;Data Source= $sql_server\$sql_instance;Initial Catalog=$base;User ID=$user;Password=$password;"
    }
    else {
        #        $ConnectionSQLString = "Provider=SQLOLEDB;Data Source= $sql_server;Initial Catalog=$base;User ID=$user;Password=$password;"
        $ConnectionSQLString = "Data Source= $sql_server;Initial Catalog=$base;User ID=$user;Password=$password;"
    }
    $ComputerName = $env:computername
    Write-Log "Computer Name -> $ComputerName" "INFO"
    $bias = (Get-WmiObject -Class Win32_TimeZone).Bias
    Write-Log "Bias -> $bias" "INFO"
    $sqlQuery = "exec dbo.Get_Computer_Id '$ComputerName', '$bias';"
    $ComputerId = (Get-DatabaseData -connectionString $ConnectionSQLString -query $sqlQuery -isSQLServer)[1][0]
    Write-Log "Computer ID -> $ComputerId" "INFO"
}
catch {
    Write-Log "SQL Сервер $sql_server не доступен" "ERROR"
    return    
}
Invoke-UpdateLastConection -ComputerName $ComputerName
$lasteventupdate = Get-UpdateLastEvent -ComputerName $ComputerName
Write-Log "Last events transfer to server $lasteventupdate" "WARN"
try {
    $Events = Get-Winevent -FilterHashTable @{LogName = 'Microsoft-Windows-PrintService/Operational'; ID = 307; StartTime = $lasteventupdate; } -ErrorAction Stop 
    $DateEvent = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Log "дата обновления логов $DateEvent" "WARN"
    Invoke-UpdateLastEvent -ComputerName $ComputerName -date $DateEvent
    $CountEvent = $Events.Count
    Write-Log "Количество не сохраненных событий печати -> $CountEvent" "INFO"    
    try {
        ForEach ($Event in $Events) {            
        # Конвертируем событие XML            
            $eventXML = [xml]$Event.ToXml()
            $PageCount = $eventXML.Event.UserData.DocumentPrinted.Param8
            $UserName = $eventXML.Event.UserData.DocumentPrinted.Param3
            $userid = Get-UserID -username $UserName
            $DocumentName = $eventXML.Event.UserData.DocumentPrinted.Param2
            $Size = $eventXML.Event.UserData.DocumentPrinted.Param7
            $Printer = $eventXML.Event.UserData.DocumentPrinted.Param5
            $date = Get-Date $eventXML.Event.System.TimeCreated.SystemTime
            Write-Log "User - $UserName; Page Count - $PageCount; Size - $Size; Printer - $Printer; Date - $date" "INFO"
            $sID = $ComputerName+(Get-Date $eventXML.Event.System.TimeCreated.SystemTime -Format "yyyyMMddHHmmssfff")
            Invoke-Event -sID $sID -computer $ComputerId -user $UserName -pages_count $PageCount -document_name $DocumentName -size $Size -printer_name $Printer -datetimeprint $date
}            
    }
    catch {
        Write-Log "Что-то пошло не так $_.FullyQualifiedErrorId" "ERROR"
    }
}
catch [Exception] {
    $strError = $_.FullyQualifiedErrorId
    if ($strError -match "NoMatchingEventsFound,Microsoft.PowerShell.Commands.GetWinEventCommand") {
        Write-Log "Не удалось найти события, соответствующие указанному условию выбора"  "WARN"  
        Write-Log "LogName = 'Microsoft-Windows-PrintService/Operational'; ID = 307; StartTime = $lasteventupdate;" "ERROR"        
    }
}
Write-Log "========================          Завершаем работу скрипта          ========================" "INFO"