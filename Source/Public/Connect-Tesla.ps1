function Connect-Tesla {
    [CmdletBinding(DefaultParameterSetName='Credential')]
    param (
        # Credentials used to connect to Tesla API
        [Parameter(ParameterSetName = 'Credential', Mandatory)]
        [pscredential]
        $Credential,

        # Refreshtoken used to connect to Tesla API
        [Parameter(ParameterSetName = 'RefreshToken', Mandatory)]
        [securestring]
        $RefreshToken,

        # Access token used to connect to Tesla API
        [Parameter(ParameterSetName = 'AccessToken', Mandatory)]
        [securestring]
        $AccessToken
    )

    if ($pscmdlet.ParameterSetName -eq 'AccessToken') {
        $Token = [PSCustomObject]@{
            'access_token' = Unprotect-SecureString -SecureString $AccessToken
        }
    }
    else {
        $Params = @{
            Fragment = 'oauth/token'
            Method   = 'POST'
            Body     = @{
                'client_id'     = '81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384'
                'client_secret' = 'c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3'
            }
        }
    
        switch ($pscmdlet.ParameterSetName) {
            'Credential' { 
                $Params['Body']['grant_type'] = 'password'
                $Params['Body']['email'] = $Credential.UserName
                $Params['Body']['password'] = $Credential.GetNetworkCredential().Password
            }
            'RefreshToken' { 
                $Params['Body']['grant_type'] = 'refresh_token'
                $Params['Body']['refresh_token'] = Unprotect-SecureString -SecureString $RefreshToken
            }
            Default {
                throw "Unsupported parameter set name: [$($pscmdlet.ParameterSetName)]"
            }
        }
    
        $Token = Invoke-TeslaAPI @Params
    }

    $Script:TeslaConfiguration['Token'] = $Token

}