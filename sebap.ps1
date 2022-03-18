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

function Set-MyDefaultProxy {
    [cmdletbinding()]
    param (
    [Parameter(Mandatory)]
    [string]$Proxy)
    [net.webrequest]::defaultwebproxy = new-object net.webproxy $Proxy
    return $Proxy
}

function Set-Environment-Behind-Authentication-Proxy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Proxy)
    $cred = Get-Credential -Credential $env:username
    [net.webrequest]::defaultwebproxy.credentials = $cred

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


Set-MyDefaultProxy $proxy
Set-Environment-Behind-Authentication-Proxy $proxy
Write-host "このセッションでのプロキシ設定を行いました, [net.webproxy]::defaultwebproxy, http_proxy"
