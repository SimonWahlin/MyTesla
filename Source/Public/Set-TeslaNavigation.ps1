function Set-TeslaNavigation {
    [CmdletBinding()]
    param (
        # Id of Tesla Vehicle
        [ValidateLength(11, 200)]
        [ValidatePattern('\d+', ErrorMessage = '{0} is not a valid vehicle ID.')]
        [string]
        $Id,

        # Destination to share
        [string]
        $Destination
    )

    if (-not $PSBoundParameters.ContainsKey('Id')) {
        $Id = $Script:TeslaConfiguration['CurrentVehicleId']
    }

    if ([string]::IsNullOrWhiteSpace($Id)) {
        throw 'Invalid Vehicle Id, use the parameter Id or set a default Id using Select-TeslaVehicle'
    }
    
    [long]$Timestamp = [System.DateTimeOffset]::now - [System.DateTimeOffset]::UnixEpoch |
    Select-Object -ExpandProperty TotalMilliseconds
    
    $Body = @{
        "type"         = "share_ext_content_raw"
        "locale"       = "en-US"
        "value"        = @{
            "android.intent.extra.TEXT" = $Destination
        }
        "timestamp_ms" = $Timestamp
    }
    $Fragment = "/api/1/vehicles/${id}/command/share"
    Invoke-TeslaAPI -Fragment $Fragment -Method 'POST' -Body $Body -Auth -WakeUp | Select-Object -ExpandProperty response
}