#Ini section
#задаем настройки для соеднения с SQL
$sql_server = "10.193.1.161"
$user = "login_pel"
$password = "EQLwaZRj5H"
$base = "PrintLog" 

#INI секция
#настройки логирования
$writelog = $true   #пишем лог или нет
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
    [Parameter(Mandatory=$True)]
    [string]
    $Message,
    
    [Parameter(Mandatory=$False)]
    [String]
    $Level = "DEBUG"
    )

    $Null = @(Reset-Log -fileName $logFile -filesize $logSize -logcount $logCount)
    $levels = ("DEBUG","INFO","WARN","ERROR","FATAL")
    $logLevelPos = [array]::IndexOf($levels, $logLevel)
    $levelPos = [array]::IndexOf($levels, $Level)
    $Stamp = (Get-Date).toString("yyyy/MM/dd HH:mm:ss:fff")

    if ($logLevelPos -lt 0){
        Write-Log-Line "$Stamp ERROR Wrong logLevel configuration [$logLevel]"
    }
    
    if ($levelPos -lt 0){
        Write-Log-Line "$Stamp ERROR Wrong log level parameter [$Level]"
    }

    # if level parameter is wrong or configuration is wrong I still want to see the 
    # message in log
    if ($levelPos -lt $logLevelPos -and $levelPos -ge 0 -and $logLevelPos -ge 0){
        return
    }

    $Line = "$Stamp $Level $Message"
    Write-Log-Line $Line
}

function Reset-Log 
{ 
    # function checks to see if file in question is larger than the paramater specified 
    # if it is it will roll a log and delete the oldes log if there are more than x logs. 
    param([string]$fileName, [int64]$filesize = 1mb , [int] $logcount = 5) 
     
    $logRollStatus = $true 
    if(test-path $filename) 
    { 
        $file = Get-ChildItem $filename 
        if((($file).length) -ige $filesize) #this starts the log roll 
        { 
            $fileDir = $file.Directory 
            #this gets the name of the file we started with 
            $fn = $file.name
            $files = Get-ChildItem $filedir | Where-Object{$_.name -like "$fn*"} | Sort-Object lastwritetime 
            #this gets the fullname of the file we started with 
            $filefullname = $file.fullname
            #$logcount +=1 #add one to the count as the base file is one more than the count 
            for ($i = ($files.count); $i -gt 0; $i--) 
            {  
                #[int]$fileNumber = ($f).name.Trim($file.name) #gets the current number of 
                # the file we are on 
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
                    write-host "moving to $newfilename" 
                    move-item ($operatingFile.FullName) -Destination $newfilename -Force 
                } 
                elseif($i -ge $logcount) 
                { 
                    if($operatingFilenumber -eq $null) 
                    {  
                        $operatingFilenumber = $i - 1 
                        $operatingFile = $files | Where-Object{($_.name).trim($fn) -eq $operatingFilenumber} 
                        
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
                    $operatingFile = $files | Where-Object{($_.name).trim($fn) -eq ($i-1)} 
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

function debug {
    param ([string]$sData)    
    if ($writelog -eq $true) {
        Write-Log $sData
    }
}

$Events = Get-Winevent -FilterHashTable @{LogName='Microsoft-Windows-PrintService/Operational'; ID=307;} 
debug $Events.Count