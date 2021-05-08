function Get-RandomString ([int]$Length) {
    -join (Get-Random -InputObject 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789'.ToCharArray() -Count $Length)
}

function ConvertTo-SHA256Hash {
    param(
        [Parameter(Mandatory, ValueFromPipeline)]
        [string]$String
    )
    process {
        $Hasher = [System.Security.Cryptography.SHA256]::Create()
        $HashBytes = $Hasher.ComputeHash([System.Text.Encoding]::Default.GetBytes($String))
        Write-Output (ConvertTo-Hex -Bytes $HashBytes -ToUpper $false)
    }
}

function ConvertTo-Hex ([byte[]]$Bytes, [bool]$ToUpper) {
    $format = if ($ToUpper) { 'X2' } else { 'x2' }
    $HexChars = $Bytes | Foreach-Object -MemberName ToString -ArgumentList $format
    $HexString = -join $HexChars
    Write-Output $HexString
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

function Get-LoginInfo {
    param(
        [validateset('USA', 'China')]
        [string]
        $Region = 'USA'
    )
    
    $LoginInfo = @{
        'CodeVerifier' = Get-RandomString -Length 86
        'State'        = Get-RandomString -Length 20
    }
    $LoginInfo['CodeChallenge'] = $LoginInfo['CodeVerifier'] | ConvertTo-SHA256Hash | ConvertTo-Base64

    $BaseUri = $Script:AuthUrl[$Region]
    $Uri = [System.UriBuilder]::new("$BaseUri/oauth2/v3/authorize")
    $Uri.Port = -1
    
    $QueryString = [System.Web.HttpUtility]::ParseQueryString($Uri.Query)
    $QueryString['client_id'] = 'ownerapi'
    $QueryString['code_challenge'] = $LoginInfo.CodeChallenge
    $QueryString['code_challenge_method'] = 'S256'
    $QueryString['redirect_uri'] = "$BaseUri/void/callback"
    $QueryString['response_type'] = 'code'
    $QueryString['scope'] = 'openid email offline_access'
    $QueryString['state'] = $LoginInfo.State
    $Uri.Query = $QueryString.ToString()

    $Response = Invoke-WebRequest -Uri $Uri.Uri -SessionVariable 'WebSession'
    
    # $FormFields = @{}
    $FormFields = [System.Collections.Generic.Dictionary[string, string]]::new()
    [Regex]::Matches($Response.Content, 'type=\"hidden\" name=\"(?<name>.*?)\" value=\"(?<value>.*?)\"') | Foreach-Object {
        $FormFields.Add($_.Groups['name'].Value, $_.Groups['value'].Value)
    }

    $LoginInfo.FormFields = $FormFields
    $LoginInfo['Session'] = $WebSession

    return $LoginInfo
}

function Test-MfaId {
    param(
        [Parameter(Mandatory)]
        [string]
        $MfaId,

        [Parameter(Mandatory)]
        [string]
        $MfaCode,

        [Parameter(Mandatory)]
        [object]
        $LoginInfo,

        [Parameter()]
        [ValidateSet('USA', 'China')]
        $Region = 'USA'
    )

    $BaseUri = $Script:AuthUrl[$Region]
    $Uri = [System.UriBuilder]::new("$BaseUri/oauth2/v3/authorize/mfa/verify")
    $Params = @{
        Uri         = $Uri.Uri 
        Method      = 'POST' 
        Body        = @{
            'factor_id'      = $MfaId
            'passcode'       = $MfaCode
            'transaction_id' = $LoginInfo.FormFields.transaction_id
        } | ConvertTo-Json
        ContentType = 'application/json' 
        UserAgent   = 'MyTesla PowerShell Module' 
        WebSession  = $LoginInfo.Session #I hope I don't need a cookie here, but maybe I do...
        Headers     = @{
            'Accept'          = 'application/json'
            'Accept-Encoding' = 'gzip, deflate'
            'Referrer'        = $BaseUri
        }
    }
    $Response = Invoke-WebRequest @Params -ErrorAction 'Stop' 
    $Content = $Response.Content | ConvertFrom-Json
    $IsValid = [bool]$Content.data.valid
    return $IsValid
}

function Get-MFAFactorId {
    param(
        [string]
        $MfaCode,

        [object]
        $LoginInfo,
        
        [ValidateSet('USA','China')]
        [string]
        $Region = 'USA'
    )
    $BaseUri = $Script:AuthUrl[$Region]
    $Uri = [System.UriBuilder]::new("$BaseUri/oauth2/v3/authorize/mfa/factors")
    $QueryString = [System.Web.HttpUtility]::ParseQueryString($Uri.Query)
    $QueryString['transaction_id'] = $LoginInfo.FormFields.transaction_id
    $Uri.Query = $QueryString.ToString()

    $Params = @{
        Uri                = $Uri.Uri 
        Method             = 'GET' 
        UserAgent          = 'MyTesla PowerShell Module' 
        WebSession         = $LoginInfo.Session 
        MaximumRedirection = 0 
        Headers            = @{
            'Accept'          = 'application/json'
            'Accept-Encoding' = 'gzip, deflate'
        }
    }
    $Response = Invoke-RestMethod @Params -ErrorAction 'Stop'
    foreach ($MfaId in $Response.data) {
        if (Test-MfaId -MfaId $MfaId.id -MfaCode $MfaCode -LoginInfo $LoginInfo -Region $Region) {
            return $true
        }
    }
    # If we get here, MFA was invalid
    throw 'MFA not valid'

}

function Get-TeslaAuthCode {
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingPlainTextForPassword', 
        'Password', 
        Justification = 'We are sending the password as plain text in body, 
                         not really a point to have it in a securestring in this private function.'
    )]
    param(
        [string] $Username, 
        [string] $Password, 
        [string] $MfaCode, 
        [hashtable] $LoginInfo,
        [ValidateSet('USA', 'China')]
        [string] $Region = 'USA'
    )
    $LoginInfo.FormFields['identity'] = $Username
    $LoginInfo.FormFields['credential'] = $Password

    $BaseUri = $Script:AuthUrl[$Region]
    $Uri = [System.UriBuilder]::new("$BaseUri/oauth2/v3/authorize")
    $Uri.Port = -1
    $QueryString = [System.Web.HttpUtility]::ParseQueryString($Uri.Query)
    $QueryString['client_id'] = 'ownerapi'
    $QueryString['code_challenge'] = $LoginInfo.CodeChallenge
    $QueryString['code_challenge_method'] = 'S256'
    $QueryString['redirect_uri'] = "$BaseUri/void/callback"
    $QueryString['response_type'] = 'code'
    $QueryString['scope'] = 'openid email offline_access'
    $QueryString['state'] = $LoginInfo.State
    $Uri.Query = $QueryString.ToString()
    try {
        $Params = @{
            Uri                = $Uri.Uri 
            Method             = 'POST' 
            ContentType        = 'application/x-www-form-urlencoded' 
            Body               = [System.Text.Encoding]::UTF8.GetString([System.Net.Http.FormUrlEncodedContent]::new($LoginInfo.FormFields).ReadAsByteArrayAsync().Result)
            UserAgent          = 'MyTesla PowerShell Module' 
            WebSession         = $LoginInfo.Session 
            MaximumRedirection = 0 
            Headers            = @{
                'Accept'          = 'application/json'
                'Accept-Encoding' = 'gzip, deflate'
            }
        }
        $Response = Invoke-WebRequest @Params -ErrorAction 'Stop'

        if ($Response.StatusCode -eq [System.Net.HttpStatusCode]::OK -and $Response.Content.Contains('passcode')) {
            if (-not [string]::IsNullOrEmpty($MfaCode)) {
                #TODO: Implement MFA!
                # Not sure what to do with MFAID tbh
                $MFAID = Get-MFAFactorId -MfaCode $MfaCode -LoginInfo $LoginInfo -Region $Region
                $Code = Get-TeslaAuthCodeMfa -Region $Region -LoginInfo $LoginInfo
                return $Code
                # throw 'MFA support not implemented'
            }
            else {
                throw 'MFA code is required.'
            }

        }
        else {
            throw 'Failed to get AuthCode, no redirect.'
        }
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
                    throw 'No auth code received. Please try again later.'
                }
            }
            else {
                throw 'Redirect location not found.'
            }
        }
        else {
            throw # just re-throw what ever we got
        }
    }
    
}

function Get-TeslaAuthCodeMfa {
    param(
        $LoginInfo,
        [ValidateSet('USA', 'China')]
        [string] $Region = 'USA'
    )

    $BaseUri = $Script:AuthUrl[$Region]
    $Uri = [System.UriBuilder]::new("$BaseUri/oauth2/v3/authorize")
    $Uri.Port = -1

    $Body = [System.Collections.Generic.Dictionary[string,string]]::new()
    $Body.Add('transaction_id',$LoginInfo.FormFields['transaction_id'])

    $QueryString = [System.Web.HttpUtility]::ParseQueryString($Uri.Query)
    $QueryString['client_id'] = 'ownerapi'
    $QueryString['code_challenge'] = $LoginInfo.CodeChallenge
    $QueryString['code_challenge_method'] = 'S256'
    $QueryString['redirect_uri'] = "$BaseUri/void/callback"
    $QueryString['response_type'] = 'code'
    $QueryString['scope'] = 'openid email offline_access'
    $QueryString['state'] = $LoginInfo.State
    $Uri.Query = $QueryString.ToString()
    try {
        $Params = @{
            Uri                = $Uri.Uri
            Method             = 'POST' 
            ContentType        = 'application/x-www-form-urlencoded' 
            Body               = [System.Text.Encoding]::UTF8.GetString([System.Net.Http.FormUrlEncodedContent]::new($Body).ReadAsByteArrayAsync().Result)
            UserAgent          = 'MyTesla PowerShell Module' 
            WebSession         = $LoginInfo.Session 
            MaximumRedirection = 0 
            Headers            = @{
                'Accept'          = 'application/json'
                'Accept-Encoding' = 'gzip, deflate'
            }
        }
        $null = Invoke-WebRequest @Params -ErrorAction 'Stop'
        # If we get here, we failed, lets throw
        throw 'Failed to get AuthCode with MFA, no redirect.'
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
                    throw 'No auth code received. Please try again later.'
                }
            }
            else {
                throw 'Redirect location not found.'
            }
        }
    }
}
function Get-TeslaAuthToken {
    [CmdletBinding()]
    param (
        [string]
        $Code,
        $LoginInfo,
        [ValidateSet('USA', 'China')]
        $Region = 'USA'
    )
  
    $BaseUri = $Script:AuthUrl[$Region]
    $Uri = [System.UriBuilder]::new("$BaseUri/oauth2/v3/token")
    $Uri.Port = -1
    $Params = @{
        Uri         = $Uri.Uri 
        Method      = 'POST' 
        Body        = @{
            'grant_type'    = 'authorization_code'
            'client_id'     = 'ownerapi'
            'code'          = $Code
            'code_verifier' = $LoginInfo.CodeVerifier
            'redirect_uri'  = 'https://auth.tesla.com/void/callback'
        } | ConvertTo-Json
        ContentType = 'application/json' 
        UserAgent   = 'MyTesla PowerShell Module' 
        WebSession  = $LoginInfo.Session 
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

    $Params = @{
        Uri         = 'https://owner-api.teslamotors.com/oauth/token'
        Method      = 'POST'
        Body        = @{
            'grant_type'    = 'urn:ietf:params:oauth:grant-type:jwt-bearer'
            'client_id'     = '81527cff06843c8634fdc09e8ac0abefb46ac849f38fe1e431c2ef2106796384'
            'client_secret' = 'c7257eb71a564034f9419ee651c7d0e5f7aa6bfbd18bafb5c5c033b093bb2fa3'
        } | ConvertTo-Json
        Headers     = @{
            'Authorization' = [System.Net.Http.Headers.AuthenticationHeaderValue]::new('Bearer', $AuthToken)
        }
        ContentType = 'application/json' 
        UserAgent   = 'MyTesla PowerShell Module' 
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