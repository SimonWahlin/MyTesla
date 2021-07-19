function Get-TeslaContext {
    [CmdletBinding()]
    param ()
    
    $Script:TeslaConfiguration.Clone()
    
}