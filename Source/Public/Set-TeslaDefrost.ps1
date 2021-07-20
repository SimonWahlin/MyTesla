function Set-TeslaDefrost {
    [CmdletBinding()]
    param (
        # Id of Tesla Vehicle
        [Parameter()]
        [ValidateLength(11,200)]
        [ValidatePattern('\d+', ErrorMessage = '{0} is not a valid vehicle ID.')]
        [string]
        $Id,

        [Parameter(Mandatory)]
        [bool]
        $State
    )
    
    if(-not $PSBoundParameters.ContainsKey('Id')) {
        $Id = $Script:TeslaConfiguration['CurrentVehicleId']
    }
    
    if([string]::IsNullOrWhiteSpace($Id)) {
        throw 'Invalid Vehicle Id, use the parameter Id or set a default Id using Select-TeslaVehicle'
    }
    
    $Fragment = "api/1/vehicles/$Id/command/set_preconditioning_max"
    $Body = @{
        on = $State
    }
    Invoke-TeslaAPI -Fragment $Fragment -Body $Body -Method 'POST' -Auth -WakeUp | Select-Object -ExpandProperty response
}