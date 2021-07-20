function Set-TeslaChargeLimit {
    [CmdletBinding(DefaultParameterSetName='Standard')]
    param (
        # Set charge limit to given value in percent
        [Parameter(Mandatory, ParameterSetName='Limit')]
        [ValidateRange(50,100)]
        [Int]
        $LimitPercent,

        # Set charge limit to standard (90%)
        [Parameter(Mandatory, ParameterSetName='Standard')]
        [Switch]
        $Standard,

        # Set charge limit to max (100%)
        [Parameter(Mandatory, ParameterSetName='Max')]
        [Switch]
        $Max,

        # Id of Tesla Vehicle
        [Parameter(ParameterSetName='__AllParameterSets')]
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

    $Params = @{}
    switch ($PSCmdlet.ParameterSetName) {
        'Limit' {
            $Params['Fragment'] = "api/1/vehicles/$Id/command/set_charge_limit"
            $Params['Body'] = @{
                percent = $LimitPercent
            }
        }
        'Standard' {
            $Params['Fragment'] = "api/1/vehicles/$Id/command/charge_standard"
        }
        'Max' {
            $Params['Fragment'] = "api/1/vehicles/$Id/command/charge_max_range"
        }

        Default { throw 'This should not have happend.'}
    }

    Invoke-TeslaAPI @Params -Method 'POST' -Auth -WakeUp | Select-Object -ExpandProperty response

}