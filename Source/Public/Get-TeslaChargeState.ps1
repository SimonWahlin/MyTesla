function Get-TeslaChargeState {
    [CmdletBinding()]
    param (
        # Id of Tesla Vehicle
        [Parameter()]
        [ValidateLength(11, 200)]
        [ValidatePattern('\d+', ErrorMessage = '{0} is not a valid vehicle ID.')]
        [string]
        $Id
    )
    
    if (-not $PSBoundParameters.ContainsKey('Id') -and $Script:TeslaConfiguration.ContainsKey('CurrentVehicleId')) {
        $Id = $Script:TeslaConfiguration['CurrentVehicleId']
    }
    
    if ([string]::IsNullOrWhiteSpace($Id)) {
        throw 'Invalid Vehicle Id, use the parameter Id or set a default Id using Select-TeslaVehicle'
    }
    $Fragment = "api/1/vehicles/$Id/data_request/charge_state"
    Invoke-TeslaAPI -Fragment $Fragment -Method 'GET' -Auth -WakeUp | Select-Object -ExpandProperty response
}