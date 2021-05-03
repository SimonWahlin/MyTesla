function Export-TeslaContext {
    [CmdletBinding()]
    param (
        # Path to where the context should be saved
        [Parameter()]
        [String]
        $Path = "$Env:APPDATA\MyTesla\TeslaContext.json",

        # Store context as plain text
        [Parameter()]
        [switch]
        $AsPlainText,

        # Force file to be overwritten, don't warn about plain text export
        [Parameter()]
        [switch]
        $Force
    )
    
    $ParentPath = Split-Path -Path $Path -Parent
    if (-not (Test-Path -Path $ParentPath -PathType Container)) {
        $null = New-Item -Path $ParentPath -ItemType 'Directory' -ErrorAction Stop
    }

    $ConfigurationToExport = Get-TeslaContext
    if ($ConfigurationToExport.ContainsKey('Token')) {
        $ConfigurationToExport.Token = $ConfigurationToExport.Token.Clone()
    }
    
    if ($null -ne $ConfigurationToExport.Token.AccessToken) {
        if ($AsPlainText.IsPresent) {
            $ConfigurationToExport.Token.AccessToken = Unprotect-SecureString -SecureString $ConfigurationToExport.Token.AccessToken
        }
        else {
            $ConfigurationToExport.Token.AccessToken = $ConfigurationToExport.Token.AccessToken | ConvertFrom-Securestring
        }
    }

    if ($null -ne $ConfigurationToExport.Token.RefreshToken) {
        if ($AsPlainText.IsPresent) {
            $ConfigurationToExport.Token.RefreshToken = Unprotect-SecureString -SecureString $ConfigurationToExport.Token.RefreshToken
        }
        else {
            $ConfigurationToExport.Token.RefreshToken = $ConfigurationToExport.Token.RefreshToken | ConvertFrom-Securestring
        }
    }

    $JsonConfiguration = $ConfigurationToExport | ConvertTo-Json -Compress
    if (-not $AsPlainText.IsPresent) {
        $JsonConfiguration = ConvertTo-SecureString -String $JsonConfiguration -AsPlainText -Force | ConvertFrom-Securestring
    }

    $Params = @{
        Path     = $Path
        Value    = $JsonConfiguration
        Encoding = 'utf8'
    }
    if ($Force.IsPresent) {
        $Params['Force'] = $Force
    }

    Set-Content @Params
}