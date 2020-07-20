function Start-TeslaCharging {
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

    $null = Resume-TeslaVehicle -Id $Id -Wait
    
    $Fragment = "api/1/vehicles/$Id/command/charge_start"
    
    Invoke-TeslaAPI -Fragment $Fragment -Method 'POST' -Auth | Select-Object -ExpandProperty response
}