function Get-TeslaContext {
    [CmdletBinding(SupportsShouldProcess,ConfirmImpact='High')]
    param (
        [switch]
        $Force
    )
    
    if($Force -or $PSCmdlet.ShouldProcess('Will output your token information')) {
        $Script:TeslaConfiguration
    }
    
}