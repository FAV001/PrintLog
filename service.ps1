<#if ((Get-ItemPropertyValue  -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-PrintService/Operational' -Name 'Enabled') -eq 1) {
    Write-Output "Compliant"
}
else {
    Write-Output "No Compliant"   
}
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-PrintService/Operational' -Name 'Enabled' -Value '1'

#Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-PrintService/Operational'  #| Select-Object -ExpandProperty Enabled
$d = (Get-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-PrintService/Operational' -Name Enabled).Enabled
Get-ItemPropertyValue  -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-PrintService/Operational' -Name 'Enabled'
#$d = Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-PrintService/Operational' 
Write-Host $d
Set-ItemProperty -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-PrintService/Operational' -Name 'Enabled' -Value '1'
#>
$s= (Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-PrintService/Operational').GetValue('Enabled')
Write-Host $s


if ((Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WINEVT\Channels\Microsoft-Windows-PrintService/Operational').GetValue('Enabled') -eq 1) {
    Write-Output "Compliant"
}
else {
    Write-Output "No Compliant"   
}

if (Test-Path 'HKLM:\Software\Microsoft\CCM') {
    Remove-Item -Path 'HKLM:\Software\Microsoft\CCM' -Recurse
}

if (Test-Path 'HKLM:\Software\Microsoft\SMS') {
    Remove-Item -Path 'HKLM:\Software\Microsoft\SMS' -Recurse
}

if (Test-Path 'HKLM:\Software\Microsoft\ccmsetup') {
    Remove-Item -Path 'HKLM:\Software\Microsoft\ccmsetup' -Recurse
}
 
D8DEB17D34B18144D97A5A7C94F8A24C
7054D343F7993554F968B28BF1910AE5

 D8DEB17D 34B1 8144 D97A 5A7C94F8A24C
 7054D343 F799 3554 F968 B28BF1910AE5
{343D4507-997F-4553-9F86-2BB81F19A05E}
{FD794BF1-657D-43B6-B183-603277B8D6C8}
{8864FB91-94EE-4F16-A144-0D82A232049D}
{BFDADC41-FDCD-4B9C-B446-8A818D01BEA3}
{343D4507-997F-4553-9F86-2BB81F19A05E}
{D71BED8D-1B43-4418-9DA7-A5C7498F2AC4}
{8971B736-FB0A-4D07-AE81-82D40BBCD630}
{D71BED8D-1B43-4418-9DA7-A5C7498F2AC4}

Get-Item -Path 'HKLM:\Software\Microsoft\CCM'
Get-Item -Path 'HKLM:\Software\Microsoft\SMS'
Get-Item -Path 'HKLM:\Software\Microsoft\ccmsetup'
Get-Item -Path 'HKLM:\SOFTWARE\Classes\Installer\Features\8D58A6EC9B6DA974F99E0AE66588E116'
Get-Item -Path 'HKLM:\SOFTWARE\Classes\Installer\Products\8D58A6EC9B6DA974F99E0AE66588E116'
Get-Item -Path 'HKLM:\SOFTWARE\Classes\Installer\Features\1FDE90624C4330B46B43553F3BCB9413'
Get-Item -Path 'HKLM:\SOFTWARE\Classes\Installer\Products\1FDE90624C4330B46B43553F3BCB9413'
Get-Item -Path 'HKLM:\SOFTWARE\Classes\Installer\Features\F9735EACD3C5D0D4AA75CD114321B55A'
Get-Item -Path 'HKLM:\SOFTWARE\Classes\Installer\Products\F9735EACD3C5D0D4AA75CD114321B55A'
#5.0
Get-Item -Path 'HKLM:\SOFTWARE\Classes\Installer\Features\7054D343F7993554F968B28BF1910AE5'
Get-Item -Path 'HKLM:\SOFTWARE\Classes\Installer\Products\7054D343F7993554F968B28BF1910AE5'
Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{343D4507-997F-4553-9F86-2BB81F19A05E}'

Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{CE6A85D8-D6B9-479A-9FE9-A06E56881E61}'
Get-Item -Path 'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall\{2609EDF1-34C4-4B03-B634-55F3B3BC4931}'

Get-Item -Path 'HKLM:\Classes\Installer\Products\8D58A6EC9B6DA974F99E0AE66588E116'
Get-Item -Path 'HKLM:\Classes\Installer\Products\1FDE90624C4330B46B43553F3BCB9413'
Get-Item -Path 'HKLM:\Classes\Installer\Products\F9735EACD3C5D0D4AA75CD114321B55A'
Get-Item -Path 'HKLM:\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\8D58A6EC9B6DA974F99E0AE66588E116'
Get-Item -Path 'HKLM:\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\1FDE90624C4330B46B43553F3BCB9413'
Get-Item -Path 'HKLM:\Microsoft\Windows\CurrentVersion\Installer\UserData\S-1-5-18\Products\F9735EACD3C5D0D4AA75CD114321B55A'

        