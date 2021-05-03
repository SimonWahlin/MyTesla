function Select-TeslaVehicle {
    [CmdletBinding()]
    param (
        # Id of Tesla Vehicle
        [Parameter(Mandatory, ValueFromPipelineByPropertyName)]
        [ValidateLength(11,200)]
        [ValidatePattern('\d+', ErrorMessage = '{0} is not a valid vehicle ID.')]
        [string]
        $Id
    )
    
    $Script:TeslaConfiguration['CurrentVehicleId'] = $Id

}