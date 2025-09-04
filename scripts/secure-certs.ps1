<# 
  scripts\secure-certs.ps1

  Usage examples:
    # Basic (current user only)
    .\scripts\secure-certs.ps1 -BaseDir "C:\Users\Metal\voltpay\cert"

    # Explicit user + grant your Windows service identity read access
    .\scripts\secure-certs.ps1 `
      -BaseDir "C:\Users\Metal\voltpay\cert" `
      -User "Metal" `
      -ServiceIdentity "NT SERVICE\VoltPayService"

    # Dry run
    .\scripts\secure-certs.ps1 -BaseDir "C:\Users\Metal\voltpay\cert" -WhatIf
#>

[CmdletBinding(SupportsShouldProcess=$true)]
param(
  [Parameter(Mandatory=$true)]
  [string]$BaseDir,

  # Windows account that should own/read the files (defaults to current user)
  [string]$User = $env:USERNAME,

  # Optional service identity that needs READ access (e.g., a Windows Service account)
  [string]$ServiceIdentity
)

function Test-PathOrThrow {
  param([string]$Path)
  if (-not (Test-Path -LiteralPath $Path)) {
    throw "Path not found: $Path"
  }
}

function Set-DirSecurity {
  [CmdletBinding(SupportsShouldProcess=$true)]
  param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$true)][string]$User,
    [string]$ServiceIdentity
  )
  if ($PSCmdlet.ShouldProcess($Path, "Secure directory ACL")) {
    icacls $Path /inheritance:r | Out-Null
    # Grant user full control on the directory so they can manage files within
    icacls $Path /grant:r "${User}:(OI)(CI)(F)" | Out-Null
    if ($ServiceIdentity) {
      # Service gets read/execute/traverse only
      icacls $Path /grant:r "${ServiceIdentity}:(OI)(CI)(RX)" | Out-Null
    }
  }
}

function Protect-File {
  [CmdletBinding(SupportsShouldProcess=$true)]
  param(
    [Parameter(Mandatory=$true)][string]$Path,
    [Parameter(Mandatory=$true)][string]$User,
    [ValidateSet("Key","Cert","CA")]
    [string]$Type,
    [string]$ServiceIdentity
  )
  if ($PSCmdlet.ShouldProcess($Path, "Secure file ACL ($Type)")) {
    icacls $Path /inheritance:r | Out-Null

    switch ($Type) {
      "Key" {
        # Private key: user gets Read+Write; optional service gets Read only
        icacls $Path /grant:r "${User}:(R,W)" | Out-Null
        if ($ServiceIdentity) { icacls $Path /grant:r "${ServiceIdentity}:(R)" | Out-Null }
      }
      "Cert" {
        icacls $Path /grant:r "${User}:(R)" | Out-Null
        if ($ServiceIdentity) { icacls $Path /grant:r "${ServiceIdentity}:(R)" | Out-Null }
      }
      "CA" {
        icacls $Path /grant:r "${User}:(R)" | Out-Null
        if ($ServiceIdentity) { icacls $Path /grant:r "${ServiceIdentity}:(R)" | Out-Null }
      }
    }
    # Make non-key files read-only at the file attribute level (extra guard)
    if ($Type -ne "Key") {
      try { Attrib +R $Path } catch { }
    }
  }
}

# --- Validate structure -------------------------------------------------------
$ClientDir = Join-Path $BaseDir "client"
$CaDir     = Join-Path $BaseDir "ca"

Test-PathOrThrow $BaseDir
Test-PathOrThrow $ClientDir
Test-PathOrThrow $CaDir

Write-Host "Securing certificate tree:"
Write-Host "  BaseDir : $BaseDir"
Write-Host "  Client  : $ClientDir"
Write-Host "  CA      : $CaDir"
Write-Host "  User    : $User"
if ($ServiceIdentity) { Write-Host "  Service : $ServiceIdentity" }

# --- Secure directories first -------------------------------------------------
Set-DirSecurity -Path $BaseDir  -User $User -ServiceIdentity $ServiceIdentity
Set-DirSecurity -Path $ClientDir -User $User -ServiceIdentity $ServiceIdentity
Set-DirSecurity -Path $CaDir     -User $User -ServiceIdentity $ServiceIdentity

# --- Secure files -------------------------------------------------------------
# Keys: *-key.pem
Get-ChildItem -LiteralPath $ClientDir -Filter "*-key.pem" -File -ErrorAction SilentlyContinue | ForEach-Object {
  Protect-File -Path $_.FullName -User $User -Type Key -ServiceIdentity $ServiceIdentity
}

# Client certs: *-cert.pem
Get-ChildItem -LiteralPath $ClientDir -Filter "*-cert.pem" -File -ErrorAction SilentlyContinue | ForEach-Object {
  Protect-File -Path $_.FullName -User $User -Type Cert -ServiceIdentity $ServiceIdentity
}

# CA bundle(s): *.pem in CA dir
Get-ChildItem -LiteralPath $CaDir -Filter "*.pem" -File -ErrorAction SilentlyContinue | ForEach-Object {
  Protect-File -Path $_.FullName -User $User -Type CA -ServiceIdentity $ServiceIdentity
}

Write-Host "`nVerifying ACLs (icacls):`n"
icacls $ClientDir
icacls (Join-Path $ClientDir "*-key.pem")
icacls (Join-Path $ClientDir "*-cert.pem")
icacls $CaDir
icacls (Join-Path $CaDir "*.pem")

Write-Host "`nDone."