function Start-TeslaValetMode {
    [CmdletBinding()]
    param (
        # Id of Tesla Vehicle
        [Parameter()]
        [ValidateLength(11,200)]
        [ValidatePattern('\d+')]
        [string]
        $Id,

        # Optional four digit PIN code used to stop valet mode.
        [Parameter()]
        [ValidateScript({if($_ -match '^\d{4}$'){return $true}else{throw 'Invalid PIN, need to be exact four digits.'}})]
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
        on = $true
    }
    if($PSBoundParameters.ContainsKey('PIN')) {
        $Body['password'] = $PIN
    }

    Invoke-TeslaAPI -Fragment $Fragment -Method 'POST' -Auth -WakeUp -Body $Body | Select-Object -ExpandProperty response
}