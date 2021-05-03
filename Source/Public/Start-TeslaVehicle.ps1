function Start-TeslaVehicle {
    [CmdletBinding(ConfirmImpact='Low')]
    param (
        # Id of Tesla Vehicle
        [Parameter()]
        [ValidateLength(11,200)]
        [ValidatePattern('\d+', ErrorMessage = '{0} is not a valid vehicle ID.')]
        [string]
        $Id,

        [Parmameter(Mandatory)]
        [securestring]
        $Password
    )
    
    if(-not $PSBoundParameters.ContainsKey('Id')) {
        $Id = $Script:TeslaConfiguration['CurrentVehicleId']
    }
    
    if([string]::IsNullOrWhiteSpace($Id)) {
        throw 'Invalid Vehicle Id, use the parameter Id or set a default Id using Select-TeslaVehicle'
    }

    $Fragment = "api/1/vehicles/$Id/command/remote_start_drive"
    $Body = @{
        password = Unprotect-SecureString -SecureString $Password
    }
    
    Invoke-TeslaAPI -Fragment $Fragment -Method 'POST' -Body $Body -Auth -WakeUp | Select-Object -ExpandProperty response
}