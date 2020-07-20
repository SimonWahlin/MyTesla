function Wait-TeslaUserPresent {
    param (
        [Parameter(Mandatory)]
        [int]
        $TimeoutSeconds,

        [int]
        $Interval = 30
    )

    $TotalTime = 0
    while(($TotalTime -lt $TimeoutSeconds) -and (-not (Get-TeslaVehicleState).is_user_present)) {
        Start-Sleep -Seconds $Interval
        $TotalTime += $Interval
    }
}