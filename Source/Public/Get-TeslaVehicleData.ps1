function Get-TeslaVehicleData {
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

        
    $Fragment = "api/1/vehicles/$Id/vehicle_data"
    $null = Resume-TeslaVehicle -Id $Id -Wait
    Invoke-TeslaAPI -Fragment $Fragment -Method 'GET' -Auth | Select-Object -ExpandProperty response
}