$Global:SCCMSQLSERVER = "ADDC-2012"
$Global:DBNAME = "CM_VRR"
Try
{
$SQLConnection = New-Object System.Data.SQLClient.SQLConnection
$SQLConnection.ConnectionString ="server=$SCCMSQLSERVER;database=$DBNAME;Integrated Security=True;"
$SQLConnection.Open()
}
catch
{
    [System.Windows.Forms.MessageBox]::Show("Failed to connect SQL Server:") 
}

$SQLCommand = New-Object System.Data.SqlClient.SqlCommand
$SQLCommand.CommandText = "select QueryName,CollectionName from [dbo].[Collections_G] as G inner join [dbo].[Collection_Rules] as R
 on G.CollectionID = R.CollectionID where G.CollectionName = 'softwareinstallation'"
$SQLCommand.Connection = $SQLConnection

$SQLAdapter = New-Object System.Data.SqlClient.SqlDataAdapter
$SqlAdapter.SelectCommand = $SQLCommand                 
$SQLDataset = New-Object System.Data.DataSet
$SqlAdapter.fill($SQLDataset) | out-null

$tablevalue = @()
foreach ($data in $SQLDataset.tables[0])
{
$tablevalue = $data[0]
$tablevalue
} 
$SQLConnection.close()