function ConvertFrom-Timestamp {
    [CmdletBinding()]
    param (
        [parameter(Mandatory,ValueFromPipeline)]
        [double]
        $Timestamp
    )
    
    process {
        (Get-Date '1970-01-01').AddMilliseconds($Timestamp)
    }
  
}