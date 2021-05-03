function Open-TeslaChargePort {
    [CmdletBinding()]
    param (
        # Id of Tesla Vehicle
        [Parameter()]
        [ValidateLength(11, 200)]
        [ValidatePattern('\d+', ErrorMessage = '{0} is not a valid vehicle ID.')]
        [string]
        $Id
    )
    
    if (-not $PSBoundParameters.ContainsKey('Id')) {
        $Id = $Script:TeslaConfiguration['CurrentVehicleId']
    }
    
    if ([string]::IsNullOrWhiteSpace($Id)) {
        throw 'Invalid Vehicle Id, use the parameter Id or set a default Id using Select-TeslaVehicle'
    }

    #Todo: Will this work without waking up the vehicle?
    $Fragment = "api/1/vehicles/$Id/command/charge_port_door_open"
    $null = Resume-TeslaVehicle -Id $Id -Wait
    Invoke-TeslaAPI -Fragment $Fragment -Method 'POST' -Auth | Select-Object -ExpandProperty response
}