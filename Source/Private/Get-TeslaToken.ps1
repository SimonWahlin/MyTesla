function Get-TeslaToken {
    [CmdletBinding()]
    param (
        # Type of token
        [Parameter()]
        [validateset('Bearer', 'Access', 'Refresh')]
        [string]
        $Type
    )
    
    if ($null -ne $Script:TeslaConfiguration['Token']) {
        switch ($Type) {
            'Bearer' { 
                if ($null -ne $Script:TeslaConfiguration['Token'].'access_token') {
                    return 'Bearer {0}' -f $Script:TeslaConfiguration['Token'].'access_token'
                }
            }
            'Access' { 
                if ($null -ne $Script:TeslaConfiguration['Token'].'access_token') {
                    return $Script:TeslaConfiguration['Token'].'access_token'
                }
            }
            'Refresh' { 
                if ($null -ne $Script:TeslaConfiguration['Token'].'refresh_token') {
                    return $Script:TeslaConfiguration['Token'].'refresh_token'
                }
            }
            Default {
                throw "Type [$Type] not implemented"
            }
        }
    }

    throw 'Not signed in, please use Connect-Tesla to sign in to the API'
    
}