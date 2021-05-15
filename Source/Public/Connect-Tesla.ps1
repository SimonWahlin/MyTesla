function Connect-Tesla {
    [CmdletBinding(DefaultParameterSetName = 'Credential')]
    param (
        # Credentials used to connect to Tesla API
        [Parameter(ParameterSetName = 'Credential', Mandatory)]
        [pscredential]
        $Credential,

        # MFA Code from Authenticator app. Only needed if MFA is enabled on your account.
        [Parameter(ParameterSetName = 'Credential')]
        [string]
        $MFACode,

        # Refreshtoken used to connect to Tesla API
        [Parameter(ParameterSetName = 'RefreshToken', Mandatory)]
        [securestring]
        $RefreshToken,

        # Access token used to connect to Tesla API
        [Parameter(ParameterSetName = 'AccessToken', Mandatory)]
        [securestring]
        $AccessToken,

        # Region to sign in to, can be USA or China (if you are not in China, use USA)
        [Parameter(ParameterSetName = 'RefreshToken')]
        [Parameter(ParameterSetName = 'Credential')]
        [ValidateSet('USA', 'China')]
        [string]
        $Region = 'USA',

        [Parameter(ParameterSetName = 'RefreshToken')]
        [Parameter(ParameterSetName = 'Credential')]
        [switch]
        $PassThru
    )

    $ErrorActionPreference = 'Stop'
    switch ($pscmdlet.ParameterSetName) {
        'Credential' { 
            $Username = $Credential.UserName
            $Password = $Credential.GetNetworkCredential().Password

            $LoginSession = New-LoginSession -Region $Region
            $Code = Get-TeslaAuthCode -Username $Username -Password $Password -MfaCode $MFACode -LoginSession $LoginSession
            $AuthTokens = Get-TeslaAuthToken -Code $Code -LoginSession $LoginSession
            $Token = Get-TeslaAccessToken -AuthToken $AuthTokens.AccessToken
            $Token['AccessToken'] = $Token['AccessToken'] | ConvertTo-SecureString -AsPlainText -Force
            $Token['RefreshToken'] = $Token['RefreshToken'] | ConvertTo-SecureString -AsPlainText -Force
            $Token['IdToken'] = $AuthTokens.IdToken
        }
        'RefreshToken' { 
            throw 'Refresh token support not implemented'
        }
        'AccessToken' {
            $Token = [PSCustomObject]@{
                'AccessToken' = $AccessToken
            }
        }
        Default {
            throw "Unsupported parameter set name: [$($pscmdlet.ParameterSetName)]"
        }
    }

    $Script:TeslaConfiguration['Token'] = $Token
    if ($PassThru.IsPresent) {
        Write-Output $Token
    }

}