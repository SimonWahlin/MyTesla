$Dependencies = @(
    @{
        Name = 'ModuleBuilder'
        RequiredVersion = '2.0.0'
    },
    @{
        Name = 'PlatyPS'
        RequiredVersion = '0.14.1'
    }
)
$ModulesPath = './TMP/Modules'


$PSDefaultParameterValues['*-Location:StackName'] = 'GetBuildDependencies'

$RootPath = Split-Path -Path $MyInvocation.MyCommand.Path -Parent
Push-Location -Path "$RootPath/.."

if(-not (Test-Path -Path $ModulesPath)) {
    $null = New-Item -Path $ModulesPath -ItemType Directory
}

foreach($SaveModuleParam in $Dependencies) {
    Save-Module @SaveModuleParam -Path $ModulesPath
}

while(Get-Location -ErrorAction SilentlyContinue) {
    try {
        Pop-Location -ErrorAction 'Stop'
    }
    catch {
        break
    }
}

if($PSDefaultParameterValues.ContainsKey('Microsoft.PowerShell.Management\*-Location:StackName')) {
    $PSDefaultParameterValues.Remove('Microsoft.PowerShell.Management\*-Location:StackName')
}
