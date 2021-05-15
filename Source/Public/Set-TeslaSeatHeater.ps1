function Set-TeslaSeatHeater {
    [CmdletBinding()]
    param (
        # Id of Tesla Vehicle
        [Parameter()]
        [ValidateLength(11,200)]
        [ValidatePattern('\d+', ErrorMessage = '{0} is not a valid vehicle ID.')]
        [string]
        $Id,

        [Parameter(Mandatory)]
        [TeslaSeat]
        $Seat,

        [Parameter(Mandatory)]
        [ValidateRange(0,3)]
        [ValidateSet(0,1,2,3)]
        [int]
        $Level
    )
    
    if(-not $PSBoundParameters.ContainsKey('Id')) {
        $Id = $Script:TeslaConfiguration['CurrentVehicleId']
    }
    
    if([string]::IsNullOrWhiteSpace($Id)) {
        throw 'Invalid Vehicle Id, use the parameter Id or set a default Id using Select-TeslaVehicle'
    }

    $null = Resume-TeslaVehicle -Id $Id -Wait
    
    $Fragment = "api/1/vehicles/$Id/command/remote_seat_heater_request"
    $Body = @{
        heater = $Seat.value__
        level = $Level
    }
    Invoke-TeslaAPI -Fragment $Fragment -Body $Body -Method 'POST' -Auth | Select-Object -ExpandProperty response
}