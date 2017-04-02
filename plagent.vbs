' Option Explicit
On Error Resume Next 

 dim version
 '==========================================================================
'  Агент сбора и передачи лога печати Windows
'===========================================================================
'----  Author    : Andrey Filatov ------------------------------------------
 version="1.00.02"
'===========================================================================

Const adOpenStatic = 3 
Const adLockOptimistic = 3 

dim fso
dim objConnect
dim logWrite
dim LogFile
dim MaxLogSize

Class printEventObject
    dim PageCount       'Количество страниц
    dim UserName        'Пользователь 
    dim DocumentName    'имя документа
    dim Size            'размер документа
    dim Printer         'имя принтера/очередь печати
    dim Computer        'имя компьютера
    dim Time            'время печати
End Class

dim Last_connect		'DATETIME последнего соединения узла с системой
dim last_update_event	'DATETIME последнего обновления event-данных
dim printEvent          'набор данных по событиям
dim ScriptDir           'путь до скриптов
dim Bias    			'смещение времени в минутах от UTC (часовой пояс)
dim ComputerName        'имя компьютера

set printEvent = new printEventObject
set fso = CreateObject("Scripting.FileSystemObject")
set objConnect = CreateObject("ADODB.Connection")
set WshShell=CreateObject("Wscript.Shell")

ScriptDir = fso.GetParentFolderName(WScript.ScriptFullName)

'---------------SQL сервер для выгрузки --------------------
sql_server = "10.193.1.161"
user = "login_pel"
password = "EQLwaZRj5H"
base = "PrintLog"

Function WriteLn(S) 
    On Error Resume Next     
    WScript.Echo S &vbCrLf
End Function

'--------запись в лог-файл
Function log(sData)
    On Error Resume Next     
    dim ts
    dim objFSO
    dim strLogPath
    dim oLogFile
    
    Set objFSO = CreateObject("Scripting.FileSystemObject")
' предохраняемся от перезаполения  log-файлов
    If objFSO.FileExists(LogFile) Then
	    Set oLogFile = objFSO.GetFile(LogFile)
 	    If oLogFile.Size>MaxLogSize Then 'коррекция от переполнения
		    objFSO.DeleteFile(LogFile)
   	    End If
    End if	
    Set ts = objFSO.OpenTextFile(LogFile, 8, True)
    ts.Write Now() & " " & sData &vbCrLf
    ts.Close
    WriteLn(sData)
    Set ts = Nothing 
    Set objFSO = Nothing 
End Function

Function debug(sData)
    On Error Resume Next 
    if (logWrite = 1) Then
	    log(sData)
    End If
End Function

Function getBias()
    On Error Resume Next     
    dim objWMIService
    dim colItems
    Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
    Set colItems = objWMIService.ExecQuery("Select * from Win32_TimeZone")
    For Each objItem in colItems
	    Bias = objItem.Bias
    Next
	debug("Bias=> " & Bias)	
    set  objWMIService = Nothing
    set  colItems = Nothing
    getBias = Bias
End Function

Function LDate(date) 
    On Error Resume Next     
    LDate = Year(date) & "-" &  LNumber(Month(date)) & "-" & LNumber(Day(date))
End Function

Function LNumber(D) 
    On Error Resume Next     
    If(D) < 10 Then 
        D="0" & D
    End If
	LNumber = D
End Function

Function LDateTime(date) 
    On Error Resume Next     
    Year_  = LNumber(Year(date)) 
	Month_ = LNumber(Month(date))
	Day_   = LNumber(Day(date))
	Hour_  = LNumber(Hour(date))
	Minute_= LNumber(Minute(date))
	Second_= LNumber(Second(date))
    LDateTime  = Year_ & "-" &  Month_ & "-" & Day_ & " " & Hour_ &  ":" & Minute_ & ":" & Second_
End Function

Function FDateTime(date) 
    On Error Resume Next     
    Year_  =LNumber(Year(date)) 
	Month_ =LNumber(Month(date))
	Day_   =LNumber(Day(date))
	Hour_  =LNumber(Hour(date))
	Minute_=LNumber(Minute(date))
	Second_=LNumber(Second(date))
    FDateTime  = Year_ & "-" &  Month_ & "-" & Day_ & "-" & Hour_ &  "" & Minute_ & "" & Second_
End Function

Function ping(strHost)
    On Error Resume Next     
    dim objWMIService
    dim colPings
	strComputer = "."
	Set objWMIService = GetObject("winmgmts:\\" & strComputer & "\root\cimv2")
	Set colPings = objWMIService.ExecQuery ("Select * From Win32_PingStatus where Address = '" & strHost & "'")
	For Each objStatus in colPings
	    If IsNull(objStatus.StatusCode) or objStatus.StatusCode<>0 Then
		    ping=0
	    Else
		    ping=1
	    End If
	Next
	set  objWMIService=Nothing
    set  colPings=Nothing
End Function

Function ConnectToSQL(connectStr)
    On Error Resume Next     
    objConnect.ConnectionTimeout=15
    objConnect.CommandTimeout=30
    objConnect.Open connectStr
    debug("(SQL) connect initialization.... " )
    ConnectToSQL = objConnect.Errors.Count
    debug("ConnectToSQL result ->  " &  ConnectToSQL)
End Function

Function sql_open()
    On Error Resume Next
    sql_open = -1
    If (ping(sql_server)=1) Then
        log("connected to " & sql_server)
  	    sql_open=ConnectToSQL("Provider=SQLOLEDB;Data Source=" & sql_server & "\sqlexpress;" & "Initial Catalog=" & base & ";" & "User ID=" & user & ";Password=" & password & ";")
	    Else 
          log("not ping SQL server " & sql_server)
     End If
end Function

function SQL_Error(objConnect)
  On Error Resume Next     
    SQL_Error= ""
    if objConnect.Errors.Count > 0 Then 
	    for i = 0 to objConnect.Errors.Count - 1
	     SQL_Error= SQL_Error & " " & objConnect.Errors(i).Source & " Error " & objConnect.Errors(i).Number & ": " _ 
                	& vbTab & objConnect.Errors(i).Description & " " _ 
        	        & vbTab & "(SQL state = " & objConnect.Errors(i).SqlState & ")"
	      next 
	else 
      SQL_Error="Нет ошибок при обращении к базе данных."	
   end If	
end function

Sub executeSQL(sql)
    On Error Resume Next     
    dim Recordset
    Set Recordset = CreateObject("ADODB.Recordset")
    debug("(SQL) " & sql)
    set Recordset=objConnect.Execute(sql)
    If (objConnect.Errors.Count > 0) Then 
        debug(SQL_Error(objConnect))
    End If
    set Recordset=Nothing
End Sub

Function sql_close()
    On Error Resume Next
    debug("Завершение подключения к серверу...")                   
    objConnect.Close	
End Function

Function check_pc_reg(name, Bias)
    On Error Resume Next     
    dim Recordset
    dim Result
    dim strPC_OU_first,strPC_OU_full
    Set Recordset = CreateObject("ADODB.Recordset")
    If sql_open()=0 Then        
        Result=false
	    debug("Проверяем есть ли зарегистрированный ПК с именем " & name)
	    debug("exec dbo.check_computer_reg @name = '" & name & "'")
        Set Recordset=objConnect.Execute("exec dbo.check_computer_reg '" & name & "';")
		If objConnect.Errors.Count >0 Then            
  		    debug("SQL_Error=> " & SQL_Error(objConnect))
		End If 	
		log("SQL=>" & Recordset.Fields(1).Value)	
		log("SQL=>" & name)	
	    If (trim(Recordset.Fields(1).Value)<>trim(name)) Then  ' ----------- регистрируем ПК если его нет в базе ----------
            log("Узел с именем = " & name & " не обнаружен в системе" )
            strPC_OU_full = get_pc_ou_full(name)
            strPC_OU_first = get_pc_ou_first(strPC_OU_full)
			executeSQL("exec dbo.add_computer '" & name & "','" & Bias & "','" & strPC_OU_first & "','"& strPC_OU_full &"';")
'			call executeSQL("exec dbo.add_computer @name = '" & name & "', @bias = '" & Bias & "', @ou = '" & strPC_OU_first & "',@distinguishedName = '"& strPC_OU_full &"'")
            If objConnect.Errors.Count > 0 Then
  			    debug("SQL_Error=> " & SQL_Error(objConnect) )
            else 
		 	    debug("зарегистрировали ПК с именем = " & name & " в базе" )
		  	  	Result=true
			end If
		else
            Last_connect = Recordset.Fields(5).Value		'DATETIME последнего соединения узла с системой
            last_update_event = Recordset.Fields(6).Value	'DATETIME последнего обновления event-данных
		 	debug("есть зарегистрированный компьютер с именем  =  " & name & " в базе" )
   			Result=true
        End If
        sql_close()
    End If
    set Recordset=Nothing
    check_pc_reg=Result
End Function

Sub update_pc_last_connect(name)
' обновляем датувремя последнего обращения к базе
    On Error Resume Next
    dim sql
    debug("Обновление датувремя последнего обращения к базе ")
    if sql_open()=0 Then
        sql = "exec dbo.update_pc_last_connect '" & name & "';"
        executeSQL(sql)
	    sql_close()
    end if
End Sub

Sub update_pc_last_event(name)
' обновляем датувремя последнего обращения к базе
    On Error Resume Next
    dim sql
    debug("Обновление датувремя последнего обращения к базе ")
    if sql_open()=0 Then
        sql = "exec dbo.update_pc_last_event '" & name & "';"
        executeSQL(sql)
	    sql_close()
    end if
End Sub

Function get_pc_ou_full(name)
'Возвращает по имени ПК distinguishedName из AD
'distinguishedName: CN=WDVAM0010999,OU=PCs,OU=Blagoveshchensk,OU=LOCATIONS,OU=_Amursky,DC=DV,DC=RT,DC=RU
    On Error Resume Next 
    Dim adoCommand, adoConnection, strBase, strFilter, strAttributes
    Dim objRootDSE, strDNSDomain, strQuery, adoRecordset
    ', strName, strCN, strDistinguishedName

 ' Setup ADO objects.
    Set adoCommand = CreateObject("ADODB.Command")
    Set adoConnection = CreateObject("ADODB.Connection")
    adoConnection.CursorLocation = 3
    adoConnection.Provider = "ADsDSOObject"
    adoConnection.Open "Active Directory Provider"
    Set adoCommand.ActiveConnection = adoConnection

 ' Search entire Active Directory domain.
    Set objRootDSE = GetObject("LDAP://RootDSE")

    strDNSDomain = objRootDSE.Get("defaultNamingContext")
    strBase = "<LDAP://" & strDNSDomain & ">"

 ' Filter on user objects.
    strFilter = "(&(objectCategory=computer)(name=" & name & "))"

 ' Comma delimited list of attribute values to retrieve.
    strAttributes = "cn,distinguishedName"

 ' Construct the LDAP syntax query.
    strQuery = strBase & ";" & strFilter & ";" & strAttributes & ";subtree"
    adoCommand.CommandText = strQuery
    adoCommand.Properties("Page Size") = 100
    adoCommand.Properties("Timeout") = 30
    adoCommand.Properties("Cache Results") = False
    result = "IsNull"

 ' Run the query.

    Set adoRecordset = adoCommand.Execute
    debug("adoRecordset.RecordCount -> " & adoRecordset.RecordCount)
    If adoRecordset.RecordCount > 0 Then
        result = adoRecordset.Fields("distinguishedName").value
    End If

 ' Clean up.
    adoRecordset.Close
    adoConnection.Close 
    Set adoCommand = Nothing
    Set adoConnection = Nothing
 	get_pc_ou_full = UCase(Mid(result,InStr(result,"OU=")))
End Function

Function get_pc_ou_first(strOU)
'возвращает первую OU
    get_pc_ou_first = UCase(Mid(strOU,InStrRev(strOU,"OU=")))
'    get_pc_ou_first = Mid(Mid(strOU,1,InStr(strOU,strDNSDomain)-2),InStrRev(Mid(strOU,1,InStr(strOU,strDNSDomain)),"=")+1)
End Function

Sub ParseEventPrint(name)
' Парсим события из журнала печати
    On Error Resume Next 
    dim objWMIService
    dim colItems
    dim colLoggedEvents
    dim sql
    dim Recordset
    dim colOperatingSystems
    dim OS
    dim SystemLogFile 
    dim EventCode
    dim colLogFiles
    dim objLogFiles
    dim objOperatingSystem

    Set Recordset = CreateObject("ADODB.Recordset")
    debug("получаем дату последнего обновления событий")
    if sql_open()=0 Then
        Set Recordset=objConnect.Execute("exec dbo.get_last_event_update '" & name & "';")
		If objConnect.Errors.Count >0 Then            
  		    debug("SQL_Error=> " & SQL_Error(objConnect))
		End If 	
		log("SQL=>" & Recordset.Fields(0).Value)	
        last_update_event = Recordset.Fields(0).Value
	    sql_close()
    end If

    debug("получаем описание ОС")
    Set objWMIService = GetObject("winmgmts:" & "{impersonationLevel=impersonate}!\\.\root\cimv2")
	Set colOperatingSystems = objWMIService.ExecQuery("Select * from Win32_OperatingSystem")
    OS = vbNullString
    For Each objOperatingSystem In colOperatingSystems
    	OS = objOperatingSystem.Caption
		Exit For
    Next
    debug("OS -> " & OS)

    ' Устанавливаем имя журнала лога и код события
    If InStr(OS,"Windows XP") > 0 Or InStr(OS,"Windows(R) XP") > 0 Or InStr(OS,"Server 2003") > 0 Then
        SystemLogFile = "System"
        EventCode = "10"
    Else
        SystemLogFile = "Microsoft-Windows-PrintService/Operational"
        EventCode = "307"
    End If

    Rec = 0
    '--> check the log for events
    Set colLogFiles = objWMIService.ExecQuery("Select * from Win32_NTLogEvent Where Logfile = '" & SystemLogFile & "' and EventCode = '" & EventCode & "'")
    For Each ObjLogFile in colLogFiles 
        Rec = 1
        Exit For
    Next


    set objWMIService = Nothing
    set colLoggedEvents= Nothing    
    set Recordset=Nothing
End Sub

'====================================Main Sub=============================
'делаем настройки
logWrite = 1            '1 - пишем в лог файл
LogFile = ScriptDir & "\plagent.log" 'имя лог файла
MaxLogSize = 2500000    'Максимальный размер лог-файла
TimerAlert=60000
Bias=getBias()          'часовой пояс
ComputerName = WshShell.ExpandEnvironmentStrings("%COMPUTERNAME%")
'last_update_event=Now()

If check_pc_reg(ComputerName, Bias) Then 'проверяем зарегистрирован ПК на сервере
    log(vbCrLf & vbCrLf &"************* Service Started " & LDateTime(Now()) & " **************")
End If

update_pc_last_connect(ComputerName)
ParseEventPrint(ComputerName)
'update_pc_last_event(ComputerName)
'get_pc_ou_first(get_pc_ou_full(ComputerName))

'Do Until Not True
'Loop


'set apcData=Nothing
set printEvent = Nothing
'set objWMIService=Nothing
set fso =Nothing
set objConnect = Nothing 
set WshShell = Nothing 
set printEvent = Nothing
