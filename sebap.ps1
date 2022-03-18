# Set-Environment-Behind-Authentication-Proxy
#Requires -Version 5.1

Param (
    [cmdletbinding()]
    [validatePattern("[0-9a-z-_.]+(:\d+)?")]
    [Parameter(Mandatory)]
    [string]$Proxy)

function ConvertFrom-MySecureString {
    param(
        [Parameter(Mandatory)]
        [securestring]$SecureString,
        [switch]$AsPlainText)
    if ($PSVersionTable.PSVersion.Major -ge 7) {
        $s = ConvertFrom-SecureString -SecureString $SecureString -AsPlainText
    } else { 
        $bs = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)
        $s = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bs)
    }
     return $s
}

function Set-WebProxy-Credentials {
    [cmdletbinding()]
    param (
    [Parameter(Mandatory)]
    [string]$Proxy,
    [Parameter(Mandatory)]
    [PSCredential]$cred
    )
    [net.webrequest]::defaultwebproxy = new-object net.webproxy $Proxy
    [net.webrequest]::defaultwebproxy.credentials = $cred
    return $Proxy
}

function Set-Http-Proxy-Environment-Variable {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Proxy,
        [Parameter(Mandatory)]
        [PSCredential]$cred
        )
    $pwd = ConvertFrom-MySecureString -SecureString $cred.Password -AsPlainText
    $encodedUser = [System.Web.HttpUtility]::UrlEncode($cred.UserName)
    $encodedPwd = [System.Web.HttpUtility]::UrlEncode($pwd)
    $ps = 'http://' + $user + $encodedUser + ':' + $encodedPwd + '@' + $Proxy
    #write-host $ps
    $env:http_proxy = $ps
    $env:https_proxy = $ps
    $env:HTTP_PROXY = $ps
    $env:HTTPS_PROXY = $ps
    return $ps
}

function Set-Environment-Behind-Authentication-Proxy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Proxy,
        [Parameter(Mandatory)]
        [PScredential]$cred
        )
    Set-WebProxy-Credentials $proxy $cred
    return Set-Http-Proxy-Environment-Variable $proxy $cred
}
$cred = Get-Credential -Credential $env:username
Set-Environment-Behind-Authentication-Proxy $proxy $cred
Write-host "このセッションでのプロキシ設定を行いました, [net.webproxy]::defaultwebproxy, http_proxy"
