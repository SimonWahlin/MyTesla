function Set-TeslaDefrost {
    [CmdletBinding()]
    param (
        # Id of Tesla Vehicle
        [Parameter()]
        [ValidateLength(11,200)]
        [ValidatePattern('\d+')]
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

    $null = Resume-TeslaVehicle -Id $Id -Wait
    
    $Fragment = "api/1/vehicles/$Id/command/set_preconditioning_max"
    $Body = @{
        on = $State
    }
    Invoke-TeslaAPI -Fragment $Fragment -Body $Body -Method 'POST' -Auth | Select-Object -ExpandProperty response
}