# sebap : Set Environment Behind Authentication Proxy

認証プロキシ配下でのPowershell Script環境のセットアップを行うツールです。

## Usage

```
PS> ./sebap.ps1  auth.proxy.in.example.com

PowerShell credential request
Enter your credentials.
User: testuser
Password for user testuser: ********

PS> $env:HTTP_PROXY    
http://testuser:password@erproxy.noc.ntt.com:50080
PS> 

## Feature

[net.webrequest]::defaultwebproxy へのプロキシオブジェクトの設定。
 これにより、必要に応じて認証ダイアログがポップアップし、パスワードを
 入力することでキャッシュされる。これによりInvoke-Web-Request系の
 アクセスをカバーする。
 
(HTTP(S)?_PROXY)/i ; パスワードがURLエンコードされたプロキシURIとして
 設定することで、環境変数を参照するコマンドをカバーする。
 
 


