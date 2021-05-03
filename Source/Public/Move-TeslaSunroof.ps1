function Move-TeslaSunroof {
    [CmdletBinding(ConfirmImpact = 'Low')]
    param (
        # Id of Tesla Vehicle
        [Parameter(ParameterSetName = '__AllParameterSets')]
        [ValidateLength(11, 200)]
        [ValidatePattern('\d+', ErrorMessage = '{0} is not a valid vehicle ID.')]
        [string]
        $Id,

        [Parmameter(Mandatory, ParameterSetName = 'State')]
        [ValidateSet('Open', 'Closed', 'Comfort', 'Vent')]
        [string]
        $State,
        
        [Parmameter(Mandatory, ParameterSetName = 'Percent')]
        [ValidateRange(0, 100)]
        [int]
        $Percent

    )
    
    if (-not $PSBoundParameters.ContainsKey('Id')) {
        $Id = $Script:TeslaConfiguration['CurrentVehicleId']
    }
    
    if ([string]::IsNullOrWhiteSpace($Id)) {
        throw 'Invalid Vehicle Id, use the parameter Id or set a default Id using Select-TeslaVehicle'
    }

    switch ($PSCmdlet.ParameterSetName) {
        'Percent' {
            $Body = @{
                State   = 'move'
                Percent = $Percent
            }
            break
        }
        'State' {
            $Body = @{
                State = $State.ToLower()
            }
            break
        }
        Default {
            throw 'Unknown parameter set'
        }
    }

    $Fragment = "api/1/vehicles/$Id/command/sun_roof_control"
    
    
    Invoke-TeslaAPI -Fragment $Fragment -Method 'POST' -Body $Body -Auth -WakeUp | Select-Object -ExpandProperty response
}