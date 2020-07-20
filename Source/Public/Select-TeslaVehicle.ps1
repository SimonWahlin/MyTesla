function Select-TeslaVehicle {
    [CmdletBinding()]
    param (
        # Id of Tesla Vehicle
        [Parameter(Mandatory)]
        [ValidateLength(11,200)]
        [ValidatePattern('\d+')]
        [string]
        $Id
    )
    
    $Script:TeslaConfiguration['CurrentVehicleId'] = $Id

}