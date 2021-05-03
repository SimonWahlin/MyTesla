<#
.NOTES
    Code taken from http://blog.majcica.com/2015/11/17/powershell-tips-and-tricks-decoding-securestring/
#>
function Unprotect-SecureString {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline)]
        [securestring]
        $SecureString
    )
    
    process {
        $bstr = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString);

        try {
            return [Runtime.InteropServices.Marshal]::PtrToStringBSTR($bstr);
        }
        finally {
            [Runtime.InteropServices.Marshal]::FreeBSTR($bstr);
        }
    }
    
}