function Lock-TeslaDoor {
    [CmdletBinding()]
    param (
        # Id of Tesla Vehicle
        [Parameter()]
        [ValidateLength(11,200)]
        [ValidatePattern('\d+')]
        [string]
        $Id
    )
    
    if(-not $PSBoundParameters.ContainsKey('Id')) {
        $Id = $Script:TeslaConfiguration['CurrentVehicleId']
    }
    
    if([string]::IsNullOrWhiteSpace($Id)) {
        throw 'Invalid Vehicle Id, use the parameter Id or set a default Id using Select-TeslaVehicle'
    }

    $Fragment = "api/1/vehicles/$Id/command/door_lock"
    $null = Resume-TeslaVehicle -Id $Id -Wait
    Invoke-TeslaAPI -Fragment $Fragment -Method 'POST' -Auth | Select-Object -ExpandProperty response
}