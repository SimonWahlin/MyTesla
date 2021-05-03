function Import-TeslaContext {
    [CmdletBinding()]
    param (
        # Path to exported Tesla context
        [Parameter()]
        [string]
        $Path = "$Env:APPDATA\MyTesla\TeslaContext.json"
    )
    
    if (-not (Test-Path -Path $Path -PathType Leaf)) {
        throw "File not found: $Path"
    }

    $ContextContent = Get-Content -Path $Path -Encoding 'utf8'

    try {
        # Try reading the context as plain json
        $TeslaContext = $ContextContent | ConvertFrom-Json -AsHashtable -ErrorAction 'Stop'
        try {
            $TeslaContext.Token.AccessToken = $TeslaContext.Token.AccessToken | ConvertTo-SecureString -AsPlainText -Force -ErrorAction 'stop'
            $TeslaContext.Token.RefreshToken = $TeslaContext.Token.RefreshToken | ConvertTo-SecureString -AsPlainText -Force -ErrorAction 'stop'
        }
        catch {
            # Ignore errors here
        }
    }
    catch {
        # Not valid plain json, try decrypting
        $TeslaContext = $ContextContent | 
        ConvertTo-SecureString -ErrorAction 'Stop' | 
        Unprotect-SecureString -ErrorAction 'Stop' | 
        ConvertFrom-Json -AsHashtable -ErrorAction 'Stop'
        $TeslaContext.Token.AccessToken = $TeslaContext.Token.AccessToken | ConvertTo-SecureString
        $TeslaContext.Token.RefreshToken = $TeslaContext.Token.RefreshToken | ConvertTo-SecureString
    }

    $Script:TeslaConfiguration = $TeslaContext
    $Script:TeslaConfiguration['LastSeen'] = [System.DateTimeOffset]::Now

}