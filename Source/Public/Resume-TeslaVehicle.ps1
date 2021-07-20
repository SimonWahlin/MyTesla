function Resume-TeslaVehicle {
    [CmdletBinding()]
    param (
        # Id of Tesla Vehicle
        [Parameter()]
        [ValidateLength(11, 200)]
        [ValidatePattern('\d+', ErrorMessage = '{0} is not a valid vehicle ID.')]
        [string]
        $Id,

        [switch]
        $Wait,

        [Parameter(DontShow)]
        [int]
        $MaxNumberOfTries = 10
    )
    
    if (-not $PSBoundParameters.ContainsKey('Id')) {
        $Id = $Script:TeslaConfiguration['CurrentVehicleId']
    }
    
    if ([string]::IsNullOrWhiteSpace($Id)) {
        throw 'Invalid Vehicle Id, use the parameter Id or set a default Id using Select-TeslaVehicle'
    }

    $Fragment = "api/1/vehicles/$Id/wake_up"
    
    Write-Verbose -Message "Waking up Tesla with Id: $Id..."
    $Response = Invoke-TeslaAPI -Fragment $Fragment -Method 'POST' -Auth | Select-Object -ExpandProperty response
    
    if ($Wait.IsPresent) {
        $NumberOfTries = 1
        $SleepTime = 2
        $SleepAddition = 2
        while ($Response.state -ne 'online' -and $NumberOfTries -le $MaxNumberOfTries) {
            Write-Verbose -Message "Waiting for car to go online..."
            Start-Sleep -Seconds $SleepTime
            $SleepAddition++
            $SleepTime += $SleepAddition
            $Response = Invoke-TeslaAPI -Fragment $Fragment -Method 'POST' -Auth | Select-Object -ExpandProperty response
        }
    }

    Write-Output $Response

}