############################################################### 
# Written by Harley Schaeffer                                 #
# Must first Install Universal Dashboard with following code: #
# Install-Module UniversalDashboard.community -AcceptLicense  #
###############################################################

Import-Module UniversalDashboard.community
$compsList = Import-Csv $PSScriptRoot\example.csv
if (!(Test-Path "$PSScriptRoot\logs\")){
    New-Item "$PSScriptRoot\logs\" -ItemType directory
}
Get-UDDashboard | Stop-UDDashboard
$Dashboard = New-UDDashboard -title "Network Monitor" -Content {
    New-UDGrid -Title "Network Monitor" -Headers @("Device", "Name", "Where", "Switch IP", "Switch Name", "Switch Port", "Up") -PageSize 100 -Properties @("Device", "Name", "Where", "SwitchIP", "SwitchName", "SwitchPort", "Up") -AutoRefresh -RefreshInterval 20 -Endpoint {
        $value1 = ""
        for($i = 0; $i -lt $compsList.count; $i++){        
            $compsList[$i].up = if(!(Test-Connection -computername $compsList[$i].Device -Quiet -Count 1)){"Down"}else{"Up"}
            if($compsList[$i].up -eq "Down"){
                Invoke-UDJavaScript -JavaScript "var audio = new Audio('/audio/dong.mp3');audio.play();"
                $value1 += "`n" + $compsList[$i].Device + " " + $compsList[$i].Name + " " + $compsList[$i].Where + " FAILED"
            }
        }
        write-host $iftttalert
        if($value1 -ne ""){
            $body = @{value1 = $value1}
            $uri = "https://maker.ifttt.com/trigger/Switch%20Down/with/key/luni6fVcjoIVVIO3nV8nQsNOt6RJCYFrznSvwB_DGmb"
            $null = Invoke-RestMethod -Method Get -Uri $Uri -Body $body
        }
        $compsList | ForEach-Object {
            $BgColor = 'green'
            $FontColor = 'white'
            if ($_.up -eq "Down") {
                $BgColor = 'red'
                $FontColor = 'white'
            }
            [PSCustomObject]@{
                Device = $_.device
                Name = $_.name
                Where = $_.where
                SwitchIP = $_.SwitchIP
                SwitchName = $_.SwitchName
                SwitchPort = $_.SwitchPort
                Up = New-UDElement -Tag 'div' -Attributes @{ style = @{ 'backgroundColor' = $BgColor; color = $fontColor } } -Content { $_.up.ToString() }
            }
        }| Select Device,Name,Where,SwitchIP,SwitchName,SwitchPort,Up | Out-UDGridData 
    }
}
Start-UDDashboard -Dashboard $Dashboard -port 10001



