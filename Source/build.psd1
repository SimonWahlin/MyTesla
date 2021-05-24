@{
    Path = "MyTesla.psd1"
    OutputDirectory = "..\bin\MyTesla"
    Prefix = '.\_PrefixCode.ps1'
    SourceDirectories = 'Classes','Private','Public'
    PublicFilter = 'Public\*.ps1'
    VersionedOutputDirectory = $true
    CopyPaths = @('../LICENSE','./en-US')
}
