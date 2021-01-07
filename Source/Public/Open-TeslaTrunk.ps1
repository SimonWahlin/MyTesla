function Open-TeslaTrunk {
    [CmdletBinding()]
    param (
        # Id of Tesla Vehicle
        [Parameter()]
        [ValidateLength(11,200)]
        [ValidatePattern('\d+', ErrorMessage = '{0} is not a valid vehicle ID.')]
        [string]
        $Id,

        # Select to upen front or rear trunk. Defaults to front (frunk)
        [ValidateSet('front','rear')]
        $WhichTrunk = 'front'
    )
    
    if(-not $PSBoundParameters.ContainsKey('Id')) {
        $Id = $Script:TeslaConfiguration['CurrentVehicleId']
    }
    
    if([string]::IsNullOrWhiteSpace($Id)) {
        throw 'Invalid Vehicle Id, use the parameter Id or set a default Id using Select-TeslaVehicle'
    }

    $Fragment = "api/1/vehicles/$Id/command/actuate_trunk"
    $Body = @{
        which_trunk = $WhichTrunk
    }
    Invoke-TeslaAPI -Fragment $Fragment -Method 'POST' -Body $Body -Auth -WakeUp | Select-Object -ExpandProperty response
}