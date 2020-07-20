# MyTesla

Control Tesla cars using PowerShell! Because why not?

Commands implemented:
* Close-TeslaChargePort
* Connect-Tesla
* Export-TeslaContext
* Get-TeslaChargeState
* Get-TeslaClimateState
* Get-TeslaDriveState
* Get-TeslaVehicle
* Get-TeslaVehicleData
* Get-TeslaVehicleState
* Import-TeslaContext
* Invoke-TeslaAPI
* Open-TeslaChargePort
* Resume-TeslaVehicle
* Select-TeslaVehicle
* Set-TeslaSeatHeater
* Set-TeslaTemperature
* Start-TeslaCharging
* Start-TeslaDefrost
* Start-TeslaHVAC
* Stop-TeslaCharging
* Stop-TeslaDefrost
* Stop-TeslaHVAC
* Wait-TeslaUserPresent

## Instructions

This module can be loaded as-is by importing MyTesla.psd1. This is mainly intended for development purposes.

To speed up module load time and minimize the amount of files that needs to be signed, distributed and installed, this module contains a build script that will package up the module into two files:

- MyTesla.psd1
- MyTesla.psm1

To build the module, make sure you have the following pre-req modules:

- ModuleBuilder (Required Version 1.7.0)

Start the build by running the following command from the Source folder:

```powershell
Invoke-Build
```

This will package all code into files located in .\bin\MyTesla. That folder is now ready to be installed, copy to any path listed in you PSModulePath environment variable and you are good to go!

---
Maintained by Simon Wahlin
