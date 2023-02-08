$file = "C:\temp\powershell_lists\list"
$date = Get-Date -Format "MM-dd-yyyy"
$outCSV = "C:\temp\Powershell_Results\results $date.csv"

# Read the list of servers from the text file
$servers = Get-Content $file

$results = foreach ($server in $servers) {
    try {
        # Get the list of drives on the server
        $drives = Get-WmiObject -ComputerName $server -Class Win32_LogicalDisk -ErrorAction Stop | Where-Object { $_.DriveType -eq 3 }

        # Calculate the total free space on the server
        $totalFreeSpace = [Math]::Round(($drives | Measure-Object -Property FreeSpace -Sum).Sum / 1GB, 2)

        # Create an object to store the server name and free space
        [PSCustomObject]@{
            Server = $server
            FreeSpace = $totalFreeSpace
        }
    }
    catch {
        [PSCustomObject]@{
            Server = $server
            FreeSpace = "Unable to reach server"
        }
        continue
    }
}

# Sort the results by free space from lowest to highest
$results | Sort FreeSpace | Export-Csv $outCSV -NoTypeInformation