function Revoke-TeslaToken {
    [CmdletBinding()]
    param (
        # Token to revoke
        [Parameter()]
        [securestring]
        $Token
    )
    
    $Body = @{
        token = Unprotect-SecureString -SecureString $Token
    }

    $Fragment = "oauth/revoke"
    Invoke-TeslaAPI -Fragment $Fragment -Method 'POST' -Body $Body | Select-Object -ExpandProperty response
}