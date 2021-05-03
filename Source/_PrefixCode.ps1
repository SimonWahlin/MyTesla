# Code in here will be prepended to top of the psm1-file.
$Script:TeslaConfiguration = @{
    'LastSeen' = [System.DateTimeOffset]::MinValue
}

$Script:AuthUrl = @{
    'USA' = 'https://auth.tesla.com'
    'China' = 'https://auth.tesla.cn'
}