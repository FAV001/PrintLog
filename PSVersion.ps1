# PSVersion.ps1
$temp = get-host
$PSHostVersion = (get-host).Version.Major
if ( $PSHostVersion -eq "4" )
{
    $PSHostVersion
    Write-Host "Compliant"
}

elseif ( $PSHostVersion -le "3" )
{
    $PSHostVersion
    Write-Host "Non-Compliant"
}