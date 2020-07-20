function Import-TeslaContext {
    [CmdletBinding()]
    param (
        # Path to exported Tesla context
        [Parameter()]
        [string]
        $Path = "$Env:APPDATA\MyTesla\TeslaContext.json"
    )
    
    if(-not (Test-Path -Path $Path -PathType Leaf)) {
        throw "File not found: $Path"
    }

    $ContextContent = Get-Content -Path $Path -Encoding 'utf8'

    try {
        $TeslaContext = $ContextContent | ConvertFrom-Json -AsHashtable -ErrorAction 'Stop'
    }
    catch {
        $TeslaContext = $ContextContent | 
            ConvertTo-SecureString -ErrorAction 'Stop' | 
            Unprotect-SecureString -ErrorAction 'Stop' | 
            ConvertFrom-Json -AsHashtable -ErrorAction 'Stop'
    }

    $Script:TeslaConfiguration = $TeslaContext

}