function Stop-TeslaValetMode {
    [CmdletBinding()]
    param (
        # Id of Tesla Vehicle
        [Parameter()]
        [ValidateLength(11,200)]
        [ValidatePattern('\d+', ErrorMessage = '{0} is not a valid vehicle ID.')]
        [string]
        $Id,

        # Optional four digit PIN code used to stop valet mode.
        [Parameter()]
        [ValidatePattern('^\d{4}$', ErrorMessage = '{0} is not a valid PIN. Needs to be exact four digits.')]
        [string]
        $PIN
    )
    
    if(-not $PSBoundParameters.ContainsKey('Id')) {
        $Id = $Script:TeslaConfiguration['CurrentVehicleId']
    }
    
    if([string]::IsNullOrWhiteSpace($Id)) {
        throw 'Invalid Vehicle Id, use the parameter Id or set a default Id using Select-TeslaVehicle'
    }

    $Fragment = "api/1/vehicles/$Id/command/set_valet_mode"
    
    $Body = @{
        on = $false
    }
    if($PSBoundParameters.ContainsKey('PIN')) {
        $Body['password'] = $PIN
    }

    Invoke-TeslaAPI -Fragment $Fragment -Method 'POST' -Auth -WakeUp -Body $Body | Select-Object -ExpandProperty response
}