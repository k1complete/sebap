# Set-Environment-Behind-Authentication-Proxy
#Requires -Version 5.1

Param (
    [cmdletbinding()]
    [validatePattern("[0-9a-z-_.]+(:\d+)?")]
    [Parameter(Mandatory)]
    [string]$Proxy,
    [cmdletbinding()]
    [validateSet("process", "user", "machine")]
    [string]$Scope = "process")

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
        [PSCredential]$cred,
        [string]$scope
        )
    #import assembly 'System.Web' for HttpUtility
    $result = Add-Type -AssemblyName System.Web
    
    $pwd = ConvertFrom-MySecureString -SecureString $cred.Password -AsPlainText
    $encodedUser = [System.Web.HttpUtility]::UrlEncode($cred.UserName)
    $encodedPwd = [System.Web.HttpUtility]::UrlEncode($pwd)
    $ps = 'http://' + $user + $encodedUser + ':' + $encodedPwd + '@' + $Proxy
    #write-host $ps
    if ($scope -eq "session") {
        $env:HTTP_PROXY = $ps
        $env:HTTPS_PROXY = $ps
    } else {
        [Environment]::SetEnvironmentVariable('HTTP_PROXY', $ps, $scope)
        [Environment]::SetEnvironmentVariable('HTTPS_PROXY', $ps, $scope)
    }
    return $ps
}

function Set-Environment-Behind-Authentication-Proxy {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [string]$Proxy,
        [Parameter(Mandatory)]
        [PScredential]$cred,
        [string]$scope
        )
    Set-WebProxy-Credentials $proxy $cred 
    return Set-Http-Proxy-Environment-Variable $proxy $cred $scope
}
try {
    $cred = Get-Credential -Credential $env:username
    Set-Environment-Behind-Authentication-Proxy $proxy $cred $scope
    $scopename = @{
     "process" = "process"
     "user" = "user"
     "machine" = "machine"
    }
    Write-host "この" $scopename.$scope "でのプロキシ設定を行いました, [net.webproxy]::defaultwebproxy, http_proxy"
} catch {
  $PSCmdlet.ThrowTerminatingError($PSItem)
}

