function Set-TeslaMediaVolume {
    [CmdletBinding(DefaultParameterSetName='Up')]
    param (
        # Id of Tesla Vehicle
        [Parameter(ParameterSetName='Up')]
        [Parameter(ParameterSetName='Down')]
        [ValidateLength(11,200)]
        [ValidatePattern('\d+', ErrorMessage = '{0} is not a valid vehicle ID.')]
        [string]
        $Id,

        # Turn volume up
        [Parameter(ParameterSetName='Up')]
        [switch]
        $Up,
        
        # Turn volume down
        [Parameter(ParameterSetName='Down')]
        [switch]
        $Down

    )
    
    if(-not $PSBoundParameters.ContainsKey('Id')) {
        $Id = $Script:TeslaConfiguration['CurrentVehicleId']
    }
    
    if([string]::IsNullOrWhiteSpace($Id)) {
        throw 'Invalid Vehicle Id, use the parameter Id or set a default Id using Select-TeslaVehicle'
    }
    
    switch ($PSCmdlet.ParameterSetName) {
        'Up' {
            $Fragment = "api/1/vehicles/$Id/command/media_volume_up"
            break
        }
        'Down' {
            $Fragment = "api/1/vehicles/$Id/command/media_volume_down"
            break
        }
        Default {
            throw 'Unexpected parameter set name.'
        }
    }
    Write-Verbose -Message "Turning volume $($PSCmdlet.ParameterSetName)"
    Invoke-TeslaAPI -Fragment $Fragment -Method 'POST' -Auth -WakeUp | Select-Object -ExpandProperty response
}