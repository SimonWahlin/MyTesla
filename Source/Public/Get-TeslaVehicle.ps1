function Get-TeslaVehicle {
    [CmdletBinding()]
    param (
        # Id of Tesla Vehicle
        [Parameter()]
        [ValidateLength(11,200)]
        [ValidatePattern('\d+', ErrorMessage = '{0} is not a valid vehicle ID.')]
        [string]
        $Id
    )
    
    $Fragment = 'api/1/vehicles'
    if($PSBoundParameters.ContainsKey('Id')) {
        $Fragment += "/$Id"
    }

    Invoke-TeslaAPI -Fragment $Fragment -Method 'GET' -Auth | Select-Object -ExpandProperty response
}