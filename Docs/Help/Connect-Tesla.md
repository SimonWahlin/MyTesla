---
external help file: MyTesla-help.xml
Module Name: MyTesla
online version: 
schema: 2.0.0
---

# Connect-Tesla

## SYNOPSIS
Connects to Tesla API using either a username and password, a refresh token or an access token.

## SYNTAX

### Credential (Default)
```
Connect-Tesla -Credential <PSCredential> [-MFACode <String>] [-Region <String>] [-PassThru]
 [<CommonParameters>]
```

### RefreshToken
```
Connect-Tesla -RefreshToken <SecureString> [-Region <String>] [-PassThru] [<CommonParameters>]
```

### AccessToken
```
Connect-Tesla -AccessToken <SecureString> [<CommonParameters>]
```

## DESCRIPTION
Connect to Tesla owner API. Access token will be stored in memory until module is unloaded.
Use Export-TeslaContext to save context on disk for import later.

Supports the following three methods:
 - Credentials: Get an access token from Tesla using username/password with optional MFACode.
 - Refresh Token: Get an access token from Tesla using a refresh token.
 - Access Token: Will just store the access token in memory without contacting Tesla.

## EXAMPLES

### Example 1
```powershell
PS C:\> $Cred = Get-Credential -UserName my.account@email.com
PS C:\> Connect-Tesla -Credential $Cred -MFACode 123456
```

Get Access Token from Tesla using username/password in combination with MFA code from authenticator app.
If MFA is not enabled on your account, just skipt he MFACode parameter.

### Example 2
```powershell
PS C:\> $RefreshToken = Read-Host -Prompt RefreshToken -AsSecureString
PS C:\> Connect-Tesla -RefreshToken $RefreshToken
```

Get Access Token from Tesla using refresh token. Use this to renew an access token.

### Example 3
```powershell
PS C:\> $AccessToken = Read-Host -Prompt AccessToken -AsSecureString
PS C:\> Connect-Tesla -AccessToken $AccessToken
```

Store access token in memory for use with other commands.

## PARAMETERS

### -AccessToken
AccessToken used to access owner API. Needs to be secure string.
A secure string can be created using either Read-Host -AsSecureString or
by converting a regular string using the command ConvertTo-SecureString with
parameters -AsPlainText and -Force.

```yaml
Type: SecureString
Parameter Sets: AccessToken
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Credential
Credential object containing a username and password for your Tesla account.
Create a credential object by running Get-Credential.

```yaml
Type: PSCredential
Parameter Sets: Credential
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -MFACode
MFA code from your authenticator app.

```yaml
Type: String
Parameter Sets: Credential
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -PassThru
Will output a context object containing access token and refresh token.

```yaml
Type: SwitchParameter
Parameter Sets: Credential, RefreshToken
Aliases:

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -RefreshToken
Refresh token used to get a new access token from Tesla.Needs to be SecureString. 
A secure string can be created using either Read-Host -AsSecureString or
by converting a regular string using the command ConvertTo-SecureString with
parameters -AsPlainText and -Force.

```yaml
Type: SecureString
Parameter Sets: RefreshToken
Aliases:

Required: True
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### -Region
Region to connect to. Can be USA or China.
If not in China, use USA.

```yaml
Type: String
Parameter Sets: Credential, RefreshToken
Aliases:
Accepted values: USA, China

Required: False
Position: Named
Default value: None
Accept pipeline input: False
Accept wildcard characters: False
```

### CommonParameters
This cmdlet supports the common parameters: -Debug, -ErrorAction, -ErrorVariable, -InformationAction, -InformationVariable, -OutVariable, -OutBuffer, -PipelineVariable, -Verbose, -WarningAction, and -WarningVariable. For more information, see [about_CommonParameters](http://go.microsoft.com/fwlink/?LinkID=113216).

## INPUTS

### None

## OUTPUTS

### System.Object
## NOTES
After connecting to Tesla, use Get-TeslaVehicle to list available vehicles.
Use Select-TeslaVehicle to select default vehicle for this session.

Both access token and default vehicle can be exported to file using Export-TeslaContext.

## RELATED LINKS
