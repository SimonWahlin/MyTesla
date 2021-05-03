function ConvertFrom-Timestamp {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [double]
        $Timestamp
    )
    
    process {
        [System.DateTimeOffset]::UnixEpoch.AddSeconds($Timestamp).ToLocalTime()
    }
}