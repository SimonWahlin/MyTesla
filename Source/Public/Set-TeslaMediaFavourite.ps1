# This verb could be Skip, Switch, Step or Set
function Set-TeslaMediaFavourite {
    [CmdletBinding(DefaultParameterSetName='Next')]
    param (
        # Id of Tesla Vehicle
        [Parameter(ParameterSetName='Next')]
        [Parameter(ParameterSetName='Prev')]
        [ValidateLength(11,200)]
        [ValidatePattern('\d+', ErrorMessage = '{0} is not a valid vehicle ID.')]
        [string]
        $Id,

        # Change to next favourite radio channel
        [Parameter(ParameterSetName='Next')]
        [switch]
        $Next,

        # Change to previous favourite radio channel
        [Parameter(ParameterSetName='Prev')]
        [switch]
        $Previous

    )

    if(-not $PSBoundParameters.ContainsKey('Id')) {
        $Id = $Script:TeslaConfiguration['CurrentVehicleId']
    }

    if([string]::IsNullOrWhiteSpace($Id)) {
        throw 'Invalid Vehicle Id, use the parameter Id or set a default Id using Select-TeslaVehicle'
    }

    switch ($PSCmdlet.ParameterSetName) {
        'Next' {
            $Fragment = "api/1/vehicles/$Id/command/media_next_fav"
            break
        }
        'Prev' {
            $Fragment = "api/1/vehicles/$Id/command/media_prev_fav"
            break
        }
        Default {
            throw 'Unexpected parameter set name.'
        }
    }
    Write-Verbose -Message "Changing to $($PSCmdlet.ParameterSetName) favourite"
    Invoke-TeslaAPI -Fragment $Fragment -Method 'POST' -Auth -WakeUp | Select-Object -ExpandProperty response
}