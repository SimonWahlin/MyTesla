function Set-TeslaTemperature {
    [CmdletBinding(DefaultParameterSetName = 'SetTemp')]
    param (
        # Id of Tesla Vehicle
        [Parameter()]
        [ValidateLength(11, 200)]
        [ValidatePattern('\d+', ErrorMessage = '{0} is not a valid vehicle ID.')]
        [string]
        $Id,

        [Parameter(Mandatory, ParameterSetName = 'SetTemp')]
        [ValidateRange(15.5, 27.5)]
        [float]
        $Temperature,
        
        [Parameter(Mandatory, ParameterSetName = 'High')]
        [Alias('Max')]
        [Switch]
        $High,
        
        [Parameter(Mandatory, ParameterSetName = 'Low')]
        [Alias('Min')]
        [Switch]
        $Low
    )
    
    if (-not $PSBoundParameters.ContainsKey('Id')) {
        $Id = $Script:TeslaConfiguration['CurrentVehicleId']
    }
    
    if ([string]::IsNullOrWhiteSpace($Id)) {
        throw 'Invalid Vehicle Id, use the parameter Id or set a default Id using Select-TeslaVehicle'
    }

    switch ($PScmdlet.ParameterSetName) {
        'SetTemp' { 
            $SetTemperature = '{0:N1}' -f $Temperature
        }
        'High' { 
            $SetTemperature = '{0:N1}' -f 28
        }
        'Low' { 
            $SetTemperature = '{0:N1}' -f 15
        }
        Default {
            throw "Invalid parameter set: $($PScmdlet.ParameterSetName)"
        }
    }

    $null = Resume-TeslaVehicle -Id $Id -Wait
    
    $Fragment = "api/1/vehicles/$Id/command/set_temps"
    $Body = @{
        driver_temp = $SetTemperature
        passenger_temp = $SetTemperature
    }
    Invoke-TeslaAPI -Fragment $Fragment -Method 'POST' -Body $Body -Auth | Select-Object -ExpandProperty response
}