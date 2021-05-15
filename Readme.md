# MyTesla

Control Tesla cars using PowerShell! Because why not?

Commands implemented:
* Close-TeslaChargePort
* Connect-Tesla
* Export-TeslaContext
* Get-TeslaChargeState
* Get-TeslaClimateState
* Get-TeslaContext
* Get-TeslaDriveState
* Get-TeslaGUISettings
* Get-TeslaVehicle
* Get-TeslaVehicleConfig
* Get-TeslaVehicleData
* Get-TeslaVehicleState
* Import-TeslaContext
* Invoke-TeslaAPI
* Invoke-TeslaHorn
* Invoke-TeslaLightFlash
* Lock-TeslaDoor
* Move-TeslaSunroof
* Open-TeslaChargePort
* Open-TeslaTrunk
* Reset-TeslaValetModePIN
* Resume-TeslaVehicle
* Revoke-TeslaToken
* Select-TeslaVehicle
* Set-TeslaChargeLimit
* Set-TeslaDefrost
* Set-TeslaMediaFavourite
* Set-TeslaMediaTrack
* Set-TeslaMediaVolume
* Set-TeslaNavigation
* Set-TeslaSeatHeater
* Set-TeslaTemperature
* Start-TeslaCharging
* Start-TeslaClimate
* Start-TeslaDefrost
* Start-TeslaSentryMode
* Start-TeslaSteeringWheelHeater
* Start-TeslaUpdate
* Start-TeslaValetMode
* Start-TeslaVehicle
* Stop-TeslaCharging
* Stop-TeslaClimate
* Stop-TeslaDefrost
* Stop-TeslaSentryMode
* Stop-TeslaSteeringWheelHeater
* Stop-TeslaValetMode
* Suspend-TeslaUpdate
* Switch-TeslaMediaPlayback
* Unlock-TeslaDoor
* Wait-TeslaUserPresent

## Installation

The MyTesla PowerShell Module is published to [PowerShell Gallery](https://www.powershellgallery.com/packages/MyTesla/).

```powershell
Install-Module -Name MyTesla
```
## Developer Instructions

If you want to run this module from source code, it can be loaded as-is by importing MyTesla.psd1. This is mainly intended for development purposes.

To speed up module load time and minimize the amount of files that needs to be signed, distributed and installed, this module contains a build script that will package up the module into two files:

- MyTesla.psd1
- MyTesla.psm1

To build the module, make sure you have the following pre-req modules:

- ModuleBuilder (Required Version 2.0.0)

Start the build by running the following command from the Source folder:

```powershell
Invoke-Build
```

This will package all code into files located in .\bin\MyTesla. That folder is now ready to be installed, copy to any path listed in you PSModulePath environment variable and you are good to go!

---

Maintained by Simon Wahlin
