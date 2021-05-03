function Start-TeslaSteeringWheelHeater {
    [CmdletBinding()]
    param (
        # Id of Tesla Vehicle
        [Parameter()]
        [ValidateLength(11,200)]
        [ValidatePattern('\d+', ErrorMessage = '{0} is not a valid vehicle ID.')]
        [string]
        $Id
    )
    
    if(-not $PSBoundParameters.ContainsKey('Id')) {
        $Id = $Script:TeslaConfiguration['CurrentVehicleId']
    }
    
    if([string]::IsNullOrWhiteSpace($Id)) {
        throw 'Invalid Vehicle Id, use the parameter Id or set a default Id using Select-TeslaVehicle'
    }
    
    $Fragment = "api/1/vehicles/$Id/command/remote_steering_wheel_heater_request"
    $Body = @{
        'on' = $true
    }
    Invoke-TeslaAPI -Fragment $Fragment -Method 'POST' -Body $Body -Auth -WakeUp | Select-Object -ExpandProperty response
}