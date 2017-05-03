Set oShell = WScript.CreateObject ("WScript.Shell")
oShell.run "cmd.exe /c wevtutil sl Microsoft-Windows-PrintService/Operational /e:true"
Set oShell = Nothing
WScript.Echo "Ok"