[CmdletBinding()]
param (
    [switch]$isNoSCCM # как запускается скрипт. По умолчанию что скрипт работает в SCCM и вывод в консоль отключается, только лог файл
)

$compliance = "No"
#Ini section
#задаем настройки для соеднения с SQL
$sql_server = "10.193.1.24"
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
    if ($isNoSCCM) {
        Write-Host $Line        
    }
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
            $files = Get-ChildItem $filedir | Where-Object{$_.name -like "$fn*"} | Sort-Object lastwritetime 
            $filefullname = $file.fullname #this gets the fullname of the file we started with 
            #$logcount +=1 #add one to the count as the base file is one more than the count 
            for ($i = ($files.count); $i -gt 0; $i--) 
            {  
                #[int]$fileNumber = ($f).name.Trim($file.name) #gets the current number of the file we are on 
                $files = Get-ChildItem $filedir | Where-Object{$_.name -like "$fn*"} | Sort-Object lastwritetime 
                $operatingFile = $files | Where-Object{($_.name).trim($fn) -eq $i} 
                if ($operatingfile) 
                 {$operatingFilenumber = ($files | Where-Object{($_.name).trim($fn) -eq $i}).name.trim($fn)} 
                else 
                {$operatingFilenumber = $null} 
 
                if(($operatingFilenumber -eq $null) -and ($i -ne 1) -and ($i -lt $logcount)) 
                { 
                    $operatingFilenumber = $i 
                    $newfilename = "$filefullname.$operatingFilenumber" 
                    $operatingFile = $files | Where-Object{($_.name).trim($fn) -eq ($i-1)} 
                    write-log "moving to $newfilename" "INFO"
                    move-item ($operatingFile.FullName) -Destination $newfilename -Force 
                } 
                elseif($i -ge $logcount) 
                { 
                    if($operatingFilenumber -eq $null) 
                    {  
                        $operatingFilenumber = $i - 1 
                        $operatingFile = $files | Where-Object{($_.name).trim($fn) -eq $operatingFilenumber}
                    } 
                    write-Log "deleting  ($operatingFile.FullName) " "WARN"
                    remove-item ($operatingFile.FullName) -Force 
                } 
                elseif($i -eq 1) 
                { 
                    $operatingFilenumber = 1 
                    $newfilename = "$filefullname.$operatingFilenumber" 
                    write-log "moving to $newfilename" "INFO"
                    move-item $filefullname -Destination $newfilename -Force 
                } 
                else 
                { 
                    $operatingFilenumber = $i +1  
                    $newfilename = "$filefullname.$operatingFilenumber" 
                    $operatingFile = $files | Where-Object{($_.name).trim($fn) -eq ($i-1)} 
                    write-log "moving to $newfilename" "INFO"
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

function Invoke-SQLQuery 	{
	[OutputType([System.Data.DataTable])]
	Param
	(
		[Parameter(Mandatory = $True, Position = 1)]
		[String[]]$QueryString,
		[Parameter(Mandatory = $True, Position = 2)]
		[String]$ConnectionString
	)
	If ($QueryString -like 'select*' -or $QueryString -like 'exec*')
	{
		try
		{
			$command = New-Object System.Data.SqlClient.SqlCommand ($QueryString, $ConnectionString)
			$adapter = New-Object System.Data.SqlClient.SqlDataAdapter ($command)
			
			#Load the Dataset
			$dataset = New-Object System.Data.DataSet
			$adapter.Fill($dataset)
			$adapter.Dispose()
		}
		catch
		{
			Write-Log $error[0] "error" 3
			Write-Log $error[0].Exception "error" 3
		}
		Remove-Variable -Name adapter -ErrorAction 0
		Remove-Variable -Name command -ErrorAction 0
		Remove-Variable -Name QueryString -ErrorAction 0
		#Remove-Variable -Name ConnectionString -ErrorAction 0
		[System.GC]::Collect()
		#Return the Dataset
		return @(, $dataset.Tables[0])
	}
	elseif ($QueryString -like 'insert*' -or $QueryString -like 'update*' -or $QueryString -like 'delete*')
	{
		$connect = New-Object System.Data.SqlClient.SqlConnection($ConnectionString)
		$command = New-Object System.Data.SqlClient.SqlCommand ($QueryString, $connect)
		$connect.Open()
		$command.ExecuteReader()
		$connect.Close()
		$command.Dispose()
		$connect.Dispose()
		Remove-Variable -Name adapter -ErrorAction 0
		Remove-Variable -Name command -ErrorAction 0
		Remove-Variable -Name connect -ErrorAction 0
		Remove-Variable -Name QueryString -ErrorAction 0
		#Remove-Variable -Name ConnectionString -ErrorAction 0
		[System.GC]::Collect()
		return $null
	}
}

function Invoke-UpdateLastConection {
    #Update last connect
    [CmdletBinding()]
    param (
        [string]$ComputerName
    )
    try {
        $sqlQuery = "exec dbo.update_pc_last_connect '$ComputerName';"
        Invoke-SQLQuery -QueryString $sqlQuery -ConnectionString $ConnectionSQLString
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
        Invoke-SQLQuery -ConnectionString $ConnectionSQLString -QueryString $sqlQuery
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
        Invoke-SQLQuery -ConnectionString $ConnectionSQLString -QueryString $sqlQuery | Out-Null
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
        $result = (Invoke-SQLQuery -ConnectionString $ConnectionSQLString -QueryString $sqlQuery)[1].Rows[0].Column1
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
        $result = Invoke-SQLQuery -ConnectionString $ConnectionSQLString -QueryString $sqlQuery
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
        $result = (Invoke-SQLQuery -ConnectionString $ConnectionSQLString -QueryString $sqlQuery)[1].Rows[0].Id
        Write-Log "получили UserID - $result" "INFO"
        return $result
    }
    catch {
        Write-Log "Что-то пошло не так $_.FullyQualifiedErrorId" "ERROR"        
    }
}
function get-ComputerID{
    [CmdletBinding()]
	param (
		[string]$Computer,
        [int]$Bias
	)
    $sqlQuery = "exec dbo.Get_Computer_Id '$ComputerName', '$bias';"
    $result = (Invoke-SQLQuery -QueryString $sqlQuery -ConnectionString $ConnectionSQLString)[1].Rows[0].id    
    return $result
}

# Основной алгоритм
Write-Log "======================   Начинаем работу  ==========================" "INFO"
try {
    Test-Connection -ComputerName $sql_server -ErrorAction Stop | Out-Null
    Write-Log "SQL Сервер $sql_server доступен" "INFO"
    if ($sql_instance -ne "") {
        $ConnectionSQLString = "Data Source= $sql_server\$sql_instance;Initial Catalog=$base;User ID=$user;Password=$password;"
    }
    else {
        $ConnectionSQLString = "Data Source= $sql_server;Initial Catalog=$base;User ID=$user;Password=$password;"
    }
}
catch {
    Write-Log "SQL Сервер $sql_server не доступен" "ERROR"
    $compliance = "Error"
    Write-Output $compliance    
    Exit -1    
}
$ComputerName = $env:computername
Write-Log "Computer Name -> $ComputerName" "INFO"
$bias = (Get-WmiObject -Class Win32_TimeZone).Bias
Write-Log "Bias -> $bias" "INFO"
$ComputerId = get-ComputerID -Computer $ComputerName -Bias $bias
Write-Log "Computer ID -> $ComputerId" "INFO"

$compliance = "Yes"
Invoke-UpdateLastConection -ComputerName $ComputerName | Out-Null
$lasteventupdate = Get-UpdateLastEvent -ComputerName $ComputerName
Write-Log "Last events transfer to server $lasteventupdate" "WARN"
try {
    $Events = Get-Winevent -FilterHashTable @{LogName = 'Microsoft-Windows-PrintService/Operational'; ID = 307; StartTime = $lasteventupdate; } -ErrorAction Stop 
    $DateEvent = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
    Write-Log "дата обновления логов $DateEvent" "WARN"
    Invoke-UpdateLastEvent -ComputerName $ComputerName -date $DateEvent | Out-Null
    $CountEvent = $Events.Count
    Write-Log "Количество не сохраненных событий печати -> $CountEvent" "INFO"    
    try {
        ForEach ($Event in $Events) {            
        # Конвертируем событие XML
            $compliance = "Update"
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
if ($isNoSCCM) {
    
}
else {
    Write-Log "compliance -> $compliance" "WARN"
    Write-Output $compliance    
}
Write-Log "========================          Завершаем работу скрипта          ========================" "INFO"
