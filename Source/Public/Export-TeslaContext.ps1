function Export-TeslaContext {
    [CmdletBinding()]
    param (
        # Path to where the context should be saved
        [Parameter()]
        [String]
        $Path = "$Env:APPDATA\MyTesla\TeslaContext.json",

        # Store context as a secure string
        [Parameter()]
        [switch]
        $AsSecureString,

        # Force file to be overwritten
        [Parameter()]
        [switch]
        $Force
    )
    
    $ParentPath = Split-Path -Path $Path -Parent
    if(-not (Test-Path -Path $ParentPath -PathType Container)) {
        $null = New-Item -Path $ParentPath -ItemType 'Directory' -ErrorAction Stop
    }

    $JsonConfiguration = $Script:TeslaConfiguration | ConvertTo-Json -Compress
    if($AsSecureString.IsPresent) {
        $JsonConfiguration = ConvertTo-SecureString -String $JsonConfiguration -AsPlainText -Force | ConvertFrom-Securestring
    }

    $Params = @{
        Path = $Path
        Value = $JsonConfiguration
        Encoding = 'utf8'
    }
    if($Force.IsPresent) {
        $Params['Force'] = $Force
    }

    Set-Content @Params
}