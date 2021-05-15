function ConvertFrom-Timestamp {
    [CmdletBinding()]
    param (
        [parameter(Mandatory, ValueFromPipeline)]
        [double]
        $Timestamp
    )
    
    process {
        [System.DateTimeOffset]::UnixEpoch.AddMilliSeconds($Timestamp).ToLocalTime()
    }
}