function Invoke-TeslaAPI {
    [CmdletBinding()]
    param (
        [string]
        $Fragment,

        [string]
        $Method,

        [object]
        $Body,

        [switch]
        $Auth,

        # Parameter help description
        [Parameter(DontShow)]
        [string]
        $BaseUri = 'https://owner-api.teslamotors.com'
    )

    $Fragment = $Fragment -replace '^/+|/+$'
    $BaseUri = $BaseUri -replace '^/+|/+$'
    
    $Params = @{
        Uri = '{0}/{1}' -f $BaseUri, $Fragment
        Method = $Method
        Headers = @{
            'Content-Type' = 'application/json'
        }
    }

    if($PSBoundParameters.ContainsKey('Body')) {
        if($Body -is [hashtable]) {
            $Params['Body'] = $Body | ConvertTo-Json
        } 
        elseif ($Body -is [string]) {
            $Params['Body'] = $Body
        }
        else {
            throw "Type $($Body.GetType().Name) is not supported as Body parameter."
        }
    }

    if($Auth.IsPresent) {
        $Token = Get-TeslaToken -Type 'Bearer'
        $Params['Headers']['Authorization'] = $Token
    }

    Invoke-RestMethod @Params
}