# This script will prepare my car for driving
# by first checking the temperature in the car.
# A temperature below DefrostTemp will trigger defrosting,
# anything above MaxCoolingTemp will trigger max cooling.

# Defrosting or MaxCooling will last for 10 minutes after that
# the climate control will stay on for an aditional 20 minutes.

# If a user is detected in the car at any time, the script will 
# stop waiting.

param(
    $TargetTemperature = 20,
    $MaxCoolingTemp = 30,
    $DefrostDemp = 5,
    $VehicleId,
    $ContextPath
)

$ImportContextParams = @{}
if($PSBoundParameters.ContainsKey('ContextPath')) {
    $Params['Path'] = $ContextPath
}

Import-TeslaContext @ImportContextParams -ErrorAction Stop


if($PSBoundParameters.ContainsKey('VehicleId')) {
    Select-TeslaVehicle -Id $VehicleId
}

$VehicleState = Get-TeslaVehicleState
if($VehicleState.is_user_present) {
    Write-Verbose -Message 'User presence detected, aborting.'
    return
}

$ClimateState = Get-TeslaClimateState

if($ClimateState.inside_temp -gt $MaxCoolingTemp) {
    $null = Set-TeslaTemperature -Min
    $null = Start-TeslaHVAC
    $Operation = 'MaxCooling'
} 
elseif ($ClimateState.inside_temp -lt $DefrostDemp)  {
    $null = Start-TeslaDefrost
    $Operation = 'MaxHeat'
} else {
    $null = Start-TeslaHVAC
    $Operation = 'HVAC'
}

if($Operation -like 'Max*') {
    Wait-TeslaUsersPresent -TimeoutSeconds 600
    $null = Set-TeslaTemperature -Temperature $TargetTemperature
}

Wait-TeslaUsersPresent -TimeoutSeconds 1200

$VehicleState = Get-TeslaVehicleState
if(-not $VehicleState.is_user_present) {
    Stop-TeslaHVAC
}
