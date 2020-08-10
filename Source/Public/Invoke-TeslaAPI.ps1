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

        # Calls Resume-TeslaVehicle to wake the car up before involing API. Will not wake up if we called the API within the last minutes.
        [switch]
        $WakeUp,

        # Parameter help description
        [Parameter(DontShow)]
        [string]
        $BaseUri = 'https://owner-api.teslamotors.com'
    )

    $Fragment = $Fragment -replace '^/+|/+$'
    $BaseUri = $BaseUri -replace '^/+|/+$'
    
    if($WakeUp.IsPresent) {
        $Now = Get-Date
        $LastSeenSince = ($Now - $Script:TeslaConfiguration['LastSeen']).TotalMinutes
        if($LastSeenSince -gt 8) {
            Write-Verbose -Message 'Waking up car...'
            $ResumeParams = @{
                Wait = $true
            }
            if($Fragment -match '^api\/1\/vehicles\/(\d+)') {
                $ResumeParams['Id'] = $Matches[1]
            }
            $null = Resume-TeslaVehicle @ResumeParams
            Write-Verbose -Message 'Car is online'
        }
        else {
            Write-Verbose -Message 'Car seen recently, no need to wake up'
        }
    }

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

    $Script:TeslaConfiguration['LastSeen'] = Get-Date
}