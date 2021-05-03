function Get-TeslaToken {
    [CmdletBinding()]
    param (
        # Type of token
        [Parameter()]
        [validateset('Bearer', 'Access', 'Refresh')]
        [string]
        $Type,

        # Auto renew token if it expires in less than this many days, set to 0 to disable autorenewal.
        [int]
        [ValidateRange(0, 45)]
        $RenewalThreshold = 10
    )

    if ( 
        $RenewalThreshold -gt 0 -and
        $null -ne $Script:TeslaConfiguration['Token'].WhenExpires -and
        $Script:TeslaConfiguration['Token'].WhenExpires -lt [System.DateTimeOffset]::Now.AddDays($RenewalThreshold)
    ) {
        try {
            Connect-Tesla -RefreshToken $Script:TeslaConfiguration['Token'].RefreshToken -ErrorAction 'Stop'
        }
        catch {
            throw 'Failed to renew token in cache.'
        }
    }

    if ($null -ne $Script:TeslaConfiguration['Token']) {
        switch ($Type) {
            'Bearer' { 
                if ($null -ne $Script:TeslaConfiguration['Token'].'AccessToken') {
                    return 'Bearer {0}' -f ($Script:TeslaConfiguration['Token'].'AccessToken' | Unprotect-SecureString)
                }
            }
            'Access' { 
                if ($null -ne $Script:TeslaConfiguration['Token'].'AccessToken') {
                    return $Script:TeslaConfiguration['Token'].'AccessToken' | Unprotect-SecureString
                }
            }
            'Refresh' { 
                if ($null -ne $Script:TeslaConfiguration['Token'].'RefreshToken') {
                    return $Script:TeslaConfiguration['Token'].'RefreshToken' | Unprotect-SecureString
                }
            }
            Default {
                throw "Type [$Type] not implemented"
            }
        }
    }

    throw 'Not signed in, please use Connect-Tesla to sign in to the API'
    
}