function Get-TeslaContext {
    [CmdletBinding()]
    param (
        [switch]
        $Force
    )
    
    $Script:TeslaConfiguration.Clone()
    
}