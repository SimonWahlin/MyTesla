function Get-RandomString {
    param (
        [Parameter(Mandatory)]
        [int]
        $Length
    )
    -join (Get-Random -InputObject 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.ToCharArray() -Count $Length)
}

function ConvertTo-SHA256Hash {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]
        $String
    )
    process {
        $Hasher = [System.Security.Cryptography.SHA256]::Create()
        $HashBytes = $Hasher.ComputeHash([System.Text.Encoding]::Default.GetBytes($String))
        $Hash = ConvertTo-Hex -Bytes $HashBytes
        Write-Output $Hash
    }
}

function ConvertTo-Hex {
    param(
        [Parameter(ValueFromPipeline)]
        [byte[]]
        $Bytes,

        [switch]
        $ToUpper
    )
    process {
        $format = if ($ToUpper.IsPresent) { 'X2' } else { 'x2' }
        $HexChars = $Bytes | Foreach-Object -MemberName ToString -ArgumentList $format
        $HexString = -join $HexChars
        Write-Output $HexString
    }
}

function ConvertTo-Base64 {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$String
    )
    process {
        [convert]::ToBase64String([System.Text.Encoding]::Default.GetBytes($String))
    }
}

function ConvertTo-UrlEncodedContent {
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [hashtable]
        $Hashtable
    )
    $Dictionary = [System.Collections.Generic.Dictionary[string, string]]::new()
    foreach ($key in $Hashtable.Keys) {
        $Dictionary.Add($key, $Hashtable[$key])
    }
    $FormUrlencodedContent = [System.Net.Http.FormUrlEncodedContent]::new($Dictionary)
    return [System.Text.Encoding]::UTF8.GetString($FormUrlencodedContent.ReadAsByteArrayAsync().Result)
}
function ConvertTo-QueryString {
    [CmdletBinding()]
    [OutputType([String])]
    param(
        [System.Collections.Specialized.OrderedDictionary]
        $Hashtable
    )
    $QueryString = [System.Web.HttpUtility]::ParseQueryString('')
    foreach ($key in $Hashtable.Keys) {
        $QueryString.Add($key, $Hashtable[$key])
    }
    return $QueryString.ToString()
}

function New-LoginSession {
    param(
        [validateset('USA', 'China')]
        [string]
        $Region = 'USA',

        [string]
        $UserAgent = 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36 Edg/91.0.864.70'
    )

    $LoginSession = @{
        'CodeVerifier' = Get-RandomString -Length 86
        'State'        = Get-RandomString -Length 20
        'Region'       = $Region
        'BaseUri'      = $Script:AuthUrl[$Region]
        'UserAgent'    = $UserAgent
    }
    $LoginSession['CodeChallenge'] = $LoginSession['CodeVerifier'] | ConvertTo-SHA256Hash | ConvertTo-Base64

    $Fragment = 'oauth2/v3/authorize'
    $Uri = [System.UriBuilder]::new('https', $LoginSession.BaseUri, 443, $Fragment)

    $Query = [ordered]@{
        'client_id'             = 'ownerapi'
        'code_challenge'        = $LoginSession.CodeChallenge
        'code_challenge_method' = 'S256'
        'redirect_uri'          = [System.UriBuilder]::new('https', $LoginSession.BaseUri, 443, 'void/callback').Uri.ToString()
        'response_type'         = 'code'
        'scope'                 = 'openid email offline_access'
        'state'                 = $LoginSession.State
    }
    $Uri.Query = ConvertTo-QueryString -Hashtable $Query

    $Params = @{
        Uri                = $Uri.Uri.ToString()
        Method             = 'GET'
        UserAgent          = $LoginSession.UserAgent
        WebSession         = $LoginSession.WebSession
        MaximumRedirection = 0
        Headers            = @{
            'Accept'          = 'application/json'
            'Accept-Encoding' = 'gzip, deflate'
        }
    }
    $Response = Invoke-WebRequest @Params -SessionVariable 'WebSession' -ErrorAction 'Stop'
    $FormFields = @{}
    [Regex]::Matches($Response.Content, 'type=\"hidden\" name=\"(?<name>.*?)\" value=\"(?<value>.*?)\"') | Foreach-Object {
        $FormFields.Add($_.Groups['name'].Value, $_.Groups['value'].Value)
    }
    $LoginSession.FormFields = $FormFields
    $LoginSession['WebSession'] = $WebSession

    return $LoginSession
}

function Get-TeslaAuthCode {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingPlainTextForPassword',
        'Password',
        Justification = 'We are sending the password as plain text in body,
                         not really a point to have it in a securestring in this private function.'
    )]
    param(
        [Parameter(Mandatory)]
        [string]
        $Username,

        [Parameter(Mandatory)]
        [string]
        $Password,

        [Parameter()]
        [string]
        $MfaCode,

        [Parameter(Mandatory)]
        [hashtable]
        $LoginSession
    )
    $LoginSession.FormFields['identity'] = $Username
    $LoginSession.FormFields['credential'] = $Password

    $Fragment = 'oauth2/v3/authorize'
    $Uri = [System.UriBuilder]::new('https', $LoginSession.BaseUri, 443, $Fragment)

    $Query = [ordered]@{
        'client_id'             = 'ownerapi'
        'code_challenge'        = $LoginSession.CodeChallenge
        'code_challenge_method' = 'S256'
        'redirect_uri'          = [System.UriBuilder]::new('https', $LoginSession.BaseUri, 443, 'void/callback').Uri.ToString()
        'response_type'         = 'code'
        'scope'                 = 'openid email offline_access'
        'state'                 = $LoginSession.State
    }
    $Uri.Query = ConvertTo-QueryString -Hashtable $Query

    # Try here to catch HTTP Redirect
    try {
        $Body = ConvertTo-UrlEncodedContent $LoginSession.FormFields
        $Params = @{
            Uri                = $Uri.Uri.ToString()
            Method             = 'POST'
            ContentType        = 'application/x-www-form-urlencoded'
            Body               = $Body
            UserAgent          = $LoginSession.UserAgent
            WebSession         = $LoginSession.WebSession
            MaximumRedirection = 0
            Headers            = @{
                'Accept'          = 'application/json'
                'Accept-Encoding' = 'gzip, deflate'
            }
        }
        $Response = Invoke-WebRequest @Params -ErrorAction 'Stop'
        if ($Response.StatusCode -eq [System.Net.HttpStatusCode]::OK -and $Response.Content.Contains('passcode')) {
            Write-Verbose -Message 'MFA Requried'
            $MFARequirements = Get-MFARequirements -LoginSession $LoginSession
            if (-not [string]::IsNullOrEmpty($MfaCode)) {
                foreach ($MFAId in $MFARequirements) {
                    if (Submit-MfaCode -MfaId $MfaId.id -MfaCode $MfaCode -LoginSession $LoginSession) {
                        $Code = Get-TeslaAuthCodeMfa -LoginSession $LoginSession
                        return $Code
                    }
                }
            }
            else {
                throw 'MFA code is required.' # use $MFARequirements here
            }

        }
        else {
            throw 'Failed to get AuthCode, no redirect.'
        }
    }
    catch [Microsoft.PowerShell.Commands.HttpResponseException] {
        if ($_.exception.response.StatusCode -eq [System.Net.HttpStatusCode]::Redirect) {
            Write-Verbose -Message 'Got redirect, parsing Location without MFA'
            [uri]$Location = $_.exception.response.headers.Location.OriginalString
            if (-not [string]::IsNullOrEmpty($Location)) {
                $Code = [System.Web.HttpUtility]::ParseQueryString($Location.Query).Get('Code')
                if (-not [string]::IsNullOrEmpty($Code)) {
                    return $Code
                }
                else {
                    throw 'No auth code received. Please try again later.'
                }
            }
            else {
                throw 'Redirect location not found.'
            }
        }
        else {
            throw
        }
    }

}

function Submit-MfaCode {
    param(
        [Parameter(Mandatory)]
        [string]
        $MfaId,

        [Parameter(Mandatory)]
        [string]
        $MfaCode,

        [Parameter(Mandatory)]
        [hashtable]
        $LoginSession
    )
    $Fragment = 'oauth2/v3/authorize/mfa/verify'
    $Uri = [System.UriBuilder]::new('https', $LoginSession.BaseUri, 443, $Fragment)
    $Params = @{
        Uri         = $Uri.Uri.ToString()
        Method      = 'POST'
        ContentType = 'application/json; charset=utf-8'
        Body        = [ordered]@{
            'factor_id'      = $MfaId
            'passcode'       = $MfaCode
            'transaction_id' = $LoginSession.FormFields.transaction_id
        } | ConvertTo-Json -Compress
        
        UserAgent   = $LoginSession.UserAgent
        WebSession  = $LoginSession.WebSession
        Headers     = @{
            'Accept'          = 'application/json'
            'Accept-Encoding' = 'gzip, deflate'
            'Referer'         = [System.UriBuilder]::new('https', $LoginSession.BaseUri, 443, $null).Uri.ToString()
        }
    }
    $Response = Invoke-WebRequest @Params -ErrorAction 'Stop'
    $Content = $Response.Content | ConvertFrom-Json
    $IsValid = [bool]$Content.data.valid
    return $IsValid
}

function Get-MFARequirements {
    param(
        [Parameter(Mandatory)]
        [hashtable]
        $LoginSession
    )
    $Fragment = 'oauth2/v3/authorize/mfa/factors'
    $Uri = [System.UriBuilder]::new('https', $LoginSession.BaseUri, 443, $Fragment)
    $Query = [ordered]@{
        'transaction_id' = $LoginSession.FormFields.transaction_id
    }
    $Uri.Query = ConvertTo-QueryString -Hashtable $Query

    $Params = @{
        Uri                = $Uri.Uri
        Method             = 'GET'
        UserAgent          = $LoginSession.UserAgent
        WebSession         = $LoginSession.WebSession
        MaximumRedirection = 0
        Headers            = @{
            'Accept'          = 'application/json'
            'Accept-Encoding' = 'gzip, deflate'
        }
    }
    $Response = Invoke-WebRequest @Params -ErrorAction 'Stop'
    $Content = $Response.Content | ConvertFrom-Json
    return $Content.data
}

function Get-TeslaAuthCodeMfa {
    param(
        [Parameter(Mandatory)]
        [hashtable]
        $LoginSession
    )

    $Fragment = 'oauth2/v3/authorize'
    $Uri = [System.UriBuilder]::new('https',$LoginSession.BaseUri,443,$Fragment)

    $Body = ConvertTo-UrlEncodedContent @{
        'transaction_id' = $LoginSession.FormFields['transaction_id']
    }

    $Query = [ordered]@{
        'client_id'             = 'ownerapi'
        'code_challenge'        = $LoginSession.CodeChallenge
        'code_challenge_method' = 'S256'
        'redirect_uri'          = [System.UriBuilder]::new('https', $LoginSession.BaseUri, 443, 'void/callback').Uri.ToString()
        'response_type'         = 'code'
        'scope'                 = 'openid email offline_access'
        'state'                 = $LoginSession.State
    }
    $Uri.Query = ConvertTo-QueryString -Hashtable $Query

    try {
        $Params = @{
            Uri                = $Uri.Uri.ToString()
            Method             = 'POST'
            ContentType        = 'application/x-www-form-urlencoded'
            Body               = $Body
            UserAgent          = $LoginSession.UserAgent
            WebSession         = $LoginSession.WebSession
            MaximumRedirection = 0
            Headers            = @{
                'Accept'          = 'application/json'
                'Accept-Encoding' = 'gzip, deflate'
            }
        }
        $Response = Invoke-WebRequest @Params -ErrorAction 'Stop'
        # If we get here, we failed. Write terminating error.
        Write-Error -Message 'Failed to get AuthCode with MFA, no redirect.' -TargetObject $Response -ErrorAction 'Stop'
    }
    catch [Microsoft.PowerShell.Commands.HttpResponseException] {
        if ($_.exception.response.StatusCode -eq [System.Net.HttpStatusCode]::Redirect) {
            [uri]$Location = $_.exception.response.headers.Location.OriginalString
            if (-not [string]::IsNullOrEmpty($Location)) {
                $Code = [System.Web.HttpUtility]::ParseQueryString($Location.Query).Get('Code')
                if (-not [string]::IsNullOrEmpty($Code)) {
                    return $Code
                }
                else {
                    Write-Error -Message 'No auth code received. Please try again later.' -Exception $_.Exception -TargetObject $_ -ErrorAction 'Stop'
                }
            }
            else {
                Write-Error -Message 'Redirect location not found.' -Exception $_.Exception -TargetObject $_ -ErrorAction 'Stop'
            }
        }
    }
}
function Get-TeslaAuthToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $Code,

        [Parameter(Mandatory)]
        [hashtable]
        $LoginSession
    )

    $Fragment = 'oauth2/v3/token'
    $Uri = [System.UriBuilder]::new('https',$LoginSession.BaseUri,443,$Fragment)
    $Params = @{
        Uri         = $Uri.Uri.ToString()
        Method      = 'POST'
        Body        = [ordered]@{
            'grant_type'    = 'authorization_code'
            'client_id'     = 'ownerapi'
            'code'          = $Code
            'code_verifier' = $LoginSession.CodeVerifier
            'redirect_uri'  = [System.UriBuilder]::new('https', $LoginSession.BaseUri, 443, 'void/callback').Uri.ToString()
        } | ConvertTo-Json -Compress
        ContentType = 'application/json; charset=utf-8'
        UserAgent   = $LoginSession.UserAgent
        WebSession  = $LoginSession.WebSession
        Headers     = @{
            'Accept'          = 'application/json'
            'Accept-Encoding' = 'gzip, deflate'
        }
    }
    $Response = Invoke-WebRequest @Params -ErrorAction 'Stop'

    $CreationTime = $Response.Headers.Date | Foreach-Object { $_ -as [System.DateTimeOffset] }
    $Content = $Response.Content | ConvertFrom-Json
    $Token = @{
        AccessToken  = $Content.access_token
        RefreshToken = $Content.refresh_token
        IdToken      = $Content.id_token
        WhenCreated  = $CreationTime
        WhenExpires  = $CreationTime.AddSeconds($Content.expires_in)
        State        = $Content.state
        Response     = $Response
    }
    return $Token
}

function Get-TeslaAccessToken {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]
        $AuthToken
    )

    $Fragment = 'oauth/token'
    $Uri = [System.UriBuilder]::new('https','owner-api.teslamotors.com',443,$Fragment)
    $Params = @{
        Uri         = $Uri.Uri.ToString()
        Method      = 'POST'
        Body        = @{
            'grant_type'    = 'urn:ietf:params:oauth:grant-type:jwt-bearer'
            'client_id'     = '81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384'
            'client_secret' = 'c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3'
        } | ConvertTo-Json -Compress
        Headers     = @{
            'Authorization' = [System.Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer', $AuthToken)
        }
        ContentType = 'application/json; charset=utf-8'
        UserAgent   = '007'
    }
    $Response = Invoke-WebRequest @Params -ErrorAction 'Stop'
    $Content = $Response.Content | ConvertFrom-Json
    $CreationTime = [System.DateTimeOffset]::FromUnixTimeSeconds($Content.created_at)
    $Token = @{
        AccessToken  = $Content.access_token
        TokenType    = $Content.token_type
        RefreshToken = $Content.refresh_token
        CreatedAt    = $CreationTime
        ExpiresAt    = $CreationTime.AddSeconds($Content.expires_in)
    }
    return $Token
}