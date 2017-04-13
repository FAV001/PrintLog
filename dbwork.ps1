[CmdletBinding()]
param (
    [switch]$isFull # отрабатывает полностью таблицы Users и Computers
)
#Ini section
#задаем настройки для соеднения с SQL
$sql_server = "10.193.1.161"
$sql_instance = "sqlexpress"
$base = "PrintLog" 

#INI секция
#настройки логирования
$logFile = "$(Get-Content Env:TEMP)\pl_dbwork.log" # имя лог файла
$logSize = 250kb    #максимальный размер файла лога, если больше пересоздаем
$logLevel = "DEBUG" # ("DEBUG","INFO","WARN","ERROR","FATAL")
$logCount = 2   #Количетсво хранимых логов при ротации
#Задаем настройки по умолчанию для полей в таблицах БД
$UsersDefaultFilialID = 11
$UsersDefaultDepartmentID
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
function get-OU {
    Param
	(
		[String]$OU
	)
    $n = $OU.IndexOf("OU=")
    $temp = $OU.Substring($n)
    return $temp
}

function get-FirstOU {
    Param
	(
		[String]$OU
	)
    $n = $OU.LastIndexOf("OU=")
    $temp = $OU.Substring($n)
    return $temp  
}

function get-IDFilial{
    Param
    (
        [string]$OU
    )
    $sTemp = (get-FirstOU -OU $OU).ToUpper()
    $sql = "select id from [PrintLog].[dbo].[Filials] Where ou = '$sTemp';"
    $result = (Invoke-SQLQuery -QueryString $sql -ConnectionString $ConnectionSQLString)[1].Rows[0].id
    Write-Log "Филиал ID - $result" "INFO"
    return $result
}

function get-IDDepartment{
    Param
    (
        [string]$Dep
    )
    $sql = "exec [PrintLog].[dbo].Get_Department_Id  '$Dep';"
    $result = (Invoke-SQLQuery -QueryString $sql -ConnectionString $ConnectionSQLString)[1].Rows[0].id
    Write-Log "Department ID - $result" "INFO"
    return $result
}

function get-IDCompany{
    Param
    (
        [string]$Comp
    )
    $sql = "exec [PrintLog].[dbo].Get_Company_Id  '$Comp';"
    $result = (Invoke-SQLQuery -QueryString $sql -ConnectionString $ConnectionSQLString)[1].Rows[0].id
    Write-Log "Company ID - $result" "INFO"
    return $result
}

function get-IDextensionAttribute2{
    Param
    (
        [string]$Ex2
    )
    $sql = "exec [PrintLog].[dbo].Get_extensionAttribute2_Id  '$Ex2';"
    $result = (Invoke-SQLQuery -QueryString $sql -ConnectionString $ConnectionSQLString)[1].Rows[0].id
    Write-Log "extensionAttribute2 - $result" "INFO"
    return $result
}

function get-IDdistinguishedName{
    Param
    (
        [string]$distinguishedName
    )
    $sql = "exec [PrintLog].[dbo].Get_distinguishedName_Id  '$distinguishedName';"
    $result = (Invoke-SQLQuery -QueryString $sql -ConnectionString $ConnectionSQLString)[1].Rows[0].id
    Write-Log "distinguishedName ID - $result" "INFO"
    return $result
}

# Основной алгоритм
Write-Log "======================   Начинаем работу  ==========================" "INFO"
Import-Module ActiveDirectory
#Import-Module SQLPS
if ($sql_instance -ne "") {
    $ConnectionSQLString = "Data Source= $sql_server\$sql_instance;Initial Catalog=$base;Integrated Security = SSPI;"
        #        $ConnectionSQLString = "Provider=SQLOLEDB;Data Source= $sql_server\$sql_instance;Initial Catalog=$base;User ID=$user;Password=$password;"
}
else {
        #        $ConnectionSQLString = "Provider=SQLOLEDB;Data Source= $sql_server;Initial Catalog=$base;User ID=$user;Password=$password;"
    $ConnectionSQLString = "Data Source= $sql_server;Initial Catalog=$base;Integrated Security = SSPI;"
}
#Обработка пользователей    
if ($isFull){
    $sql = "select * from [PrintLog].[dbo].[Users]"
}
else {
    $sql = "select * from [PrintLog].[dbo].[Users] where cn is Null"
}
$users = Invoke-SQLQuery -QueryString $sql -ConnectionString $ConnectionSQLString 
Write-Log "$users" "INFO"
foreach ($user in $users[1]) {
    try {
        $login = $user.login.ToString()
        Write-Log "Логин для обработки - $login" "INFO"
        $u = Get-ADUser -identity  $login -Properties CN,DistinguishedName,extensionAttribute1,department,company,extensionAttribute2
        $cn= $u.CN
        $dn = get-OU -OU $u.DistinguishedName
        $department = $u.department
        $ex1 = $u.extensionAttribute1
        $ex2 = $u.extensionAttribute2
        $company = $u.company
        $dnID = get-IDdistinguishedName -distinguishedName $dn
        $filialID = get-IDFilial -OU $dn
        $departmentID = get-IDDepartment -Dep $department
        $companyID = get-IDCompany -Comp $company
        $ex2ID = get-IDextensionAttribute2 -Ex2 $ex2
        $sql = "update [PrintLog].[dbo].[Users] set
            cn=N'$cn',
            extensionAttribute1='$ex1',
            distinguishedName='$dnID',
            filial_id='$filialID',
            department_id='$departmentID',
            company_id='$companyID',
            extensionAttribute2_id='$ex2ID'
        where login='$login'"
        Write-Log "Выполняем команду SQL - $sql" "INFO"
        Write-Log "$cn, $dn, $ex1" "INFO"
    }
    catch {
        if ($_.CategoryInfo.Category -eq "ObjectNotFound") {
            Write-Log "Пользователь $login в домене не найден" "WARN"
            $cn= $login
            write-log "error"                  
            $sql = "update [PrintLog].[dbo].[Users] set cn=N'$cn',extensionAttribute1=Null, distinguishedName = NULL, filial_id=$UsersDefaultFilialID where login = '$login'"
            Write-Log "Выполняем команду SQL - $sql" "INFO"
        }
    }
    $res = Invoke-SQLQuery -QueryString $sql -ConnectionString $ConnectionSQLString 
}

#Обработка компьютеров
if ($isFull){
    $sql = "select * from [PrintLog].[dbo].[Computers]"
}
else {
    $sql = "select * from [PrintLog].[dbo].[Computers] where cn is Null"
}
$computers = Invoke-SQLQuery -QueryString $sql -ConnectionString $ConnectionSQLString
Write-Log "$computers" "INFO"
foreach ($computer in $computers[1]) {
    try {
        $SAM = $computer.name.Trim()
        Write-Log "Имя ПК для обработки - $SAM" "INFO"
        $c = Get-ADComputer -identity $SAM -Properties CN,DistinguishedName
        $cn= $c.Name
        $dn = get-OU -OU $c.DistinguishedName
        $dnID = get-IDdistinguishedName -distinguishedName $dn
        $filialID = get-IDFilial -OU $dn        
        $sql = "update [PrintLog].[dbo].[Computers] set
            cn=N'$cn',
            distinguishedName_id='$dnID',
            filial_id='$filialID'
        where name=N'$SAM'"
        Write-Log "Выполняем команду SQL - $sql" "INFO"
    }
    catch {
        if ($_.CategoryInfo.Category -eq "ObjectNotFound") {
            Write-Log "Компьютер $SAM в домене не найден" "WARN"
            $cn= $SAM
            write-log "error"                  
            $sql = "update [PrintLog].[dbo].[Computers] set cn=N'$cn',distinguishedName = NULL, filial_id=$UsersDefaultFilialID where name = '$SAM'"
            Write-Log "Выполняем команду SQL - $sql" "INFO"
        }        
    }
    $res = Invoke-SQLQuery -QueryString $sql -ConnectionString $ConnectionSQLString 
}
