<#
    Smoke test for scripts/install.ps1 and scripts/uninstall.ps1.

      powershell -File .github/scripts/smoke.ps1            # Windows PowerShell 5.1
      pwsh       -File .github/scripts/smoke.ps1            # PowerShell 7
      pwsh       -File .github/scripts/smoke.ps1 autodetect # probe %APPDATA% (CI only)

    The test needs no Typora installation: the scripts only care whether a theme
    directory exists. It does hit the network, because the point is to exercise
    the real release download.

    Child scripts run in the same PowerShell host the test runs under, so both
    5.1 and 7 get covered by running this file twice.
#>

param([string]$Mode = 'explicit')

$ErrorActionPreference = 'Stop'

$root = Split-Path -Parent (Split-Path -Parent $PSScriptRoot)
$install = Join-Path $root 'scripts\install.ps1'
$uninstall = Join-Path $root 'scripts\uninstall.ps1'
$exe = if ($PSVersionTable.PSEdition -eq 'Core') { 'pwsh' } else { 'powershell' }

function Pass([string]$Message) { Write-Host "ok   $Message" }
function Fail([string]$Message) {
    Write-Host "FAIL $Message"
    exit 1
}

function New-TempDir {
    $path = Join-Path ([IO.Path]::GetTempPath()) ('bt-smoke-' + [Guid]::NewGuid().ToString('N'))
    New-Item -ItemType Directory -Path $path | Out-Null
    return $path
}

# Returns the child script's exit code and stashes its output in $script:LastOutput.
#
# ErrorActionPreference must drop to Continue around the call: Windows
# PowerShell 5.1 turns anything a native command writes to stderr into a
# terminating error while it is set to Stop, so a script that correctly refuses
# to install would blow up the test instead of reporting its exit code.
function Invoke-Script([string]$Path) {
    $previous = $ErrorActionPreference
    $ErrorActionPreference = 'Continue'
    try {
        $script:LastOutput = (& $exe -NoProfile -ExecutionPolicy Bypass -File $Path 2>&1 | Out-String)
        return $LASTEXITCODE
    }
    finally {
        $ErrorActionPreference = $previous
    }
}

if ($Mode -eq 'autodetect') {
    # Refuse to run outside CI: this mode writes into the machine's real Typora
    # theme folder and would clobber a working installation.
    if ($env:CI -ne 'true') { Fail 'autodetect mode is CI-only (it writes to the real theme folder)' }

    $themes = Join-Path $env:APPDATA 'Typora\themes'
    New-Item -ItemType Directory -Path $themes -Force | Out-Null
    Remove-Item Env:TYPORA_THEME_DIR -ErrorAction SilentlyContinue

    if ((Invoke-Script $install) -ne 0) { Fail "A10 install failed: $script:LastOutput" }
    if ($script:LastOutput -notlike "*$themes*") { Fail "A10 install output did not name $themes" }
    if (-not (Test-Path -LiteralPath (Join-Path $themes 'blue-topaz.css'))) {
        Fail 'A10 blue-topaz.css did not land in the probed folder'
    }
    Pass 'A10 probes %APPDATA%\Typora\themes'

    if ((Invoke-Script $uninstall) -ne 0) { Fail 'A10 uninstall failed' }
    if (Test-Path -LiteralPath (Join-Path $themes 'blue-topaz.css')) {
        Fail 'A10 uninstall left blue-topaz.css behind'
    }
    Pass 'A10 uninstall works against the probed folder'
    exit 0
}

$themes = New-TempDir
$env:TYPORA_THEME_DIR = $themes

'/* mine */' | Set-Content -LiteralPath (Join-Path $themes 'blue-topaz.user.css')
'/* mine */' | Set-Content -LiteralPath (Join-Path $themes 'base.user.css')

if ((Invoke-Script $install) -ne 0) { Fail 'A1 install failed' }
foreach ($item in @('blue-topaz.css', 'blue-topaz-dark.css', 'blue-topaz\font.css')) {
    if (-not (Test-Path -LiteralPath (Join-Path $themes $item))) { Fail "A1 $item missing" }
}
if (-not (Get-ChildItem -LiteralPath (Join-Path $themes 'blue-topaz') -Filter '*.woff2')) {
    Fail 'A1 no bundled woff2 fonts'
}
if ((Get-Item -LiteralPath (Join-Path $themes 'blue-topaz.css')).Length -le 10240) {
    Fail 'A1 blue-topaz.css is suspiciously small'
}
Pass 'A1 installs the three shipped items'

foreach ($item in @('blue-topaz.user.css', 'base.user.css')) {
    if (-not (Test-Path -LiteralPath (Join-Path $themes $item))) { Fail "A4 $item was removed" }
}
Pass 'A4 leaves user css alone on install'

'stale' | Set-Content -LiteralPath (Join-Path $themes 'blue-topaz\zz-stale.txt')
if ((Invoke-Script $install) -ne 0) { Fail 'A2 second run failed' }
if (-not (Test-Path -LiteralPath (Join-Path $themes 'blue-topaz.css'))) { Fail 'A2 second run broke the installation' }
Pass 'A2 re-running installs again (update path)'
if (Test-Path -LiteralPath (Join-Path $themes 'blue-topaz\zz-stale.txt')) { Fail 'A3 stale file survived the update' }
Pass 'A3 clears files dropped by an older release'

$outside = New-TempDir
$outsideCss = Join-Path $outside 'blue-topaz.css'
'ORIGINAL' | Set-Content -LiteralPath $outsideCss
Remove-Item -LiteralPath (Join-Path $themes 'blue-topaz.css') -Force
$linkMade = $true
try {
    New-Item -ItemType SymbolicLink -Path (Join-Path $themes 'blue-topaz.css') -Target $outsideCss | Out-Null
}
catch {
    $linkMade = $false
}
if ($linkMade) {
    if ((Invoke-Script $install) -eq 0) { Fail 'A5 symlink guard did not abort' }
    if ((Get-Content -LiteralPath $outsideCss -Raw).Trim() -ne 'ORIGINAL') { Fail 'A5 wrote through the symlink' }
    Pass 'A5 refuses to overwrite a symlink and leaves its target intact'
    Remove-Item -LiteralPath (Join-Path $themes 'blue-topaz.css') -Force
}
else {
    Write-Host '::warning::could not create a symlink on this runner, so A5 was not exercised'
}

$missing = Join-Path $themes 'nope\deeper'
$env:TYPORA_THEME_DIR = $missing
if ((Invoke-Script $install) -eq 0) { Fail 'A6 accepted a non-existent theme folder' }
if (Test-Path -LiteralPath $missing) { Fail 'A6 created the theme folder' }
Pass 'A6 refuses a missing folder without creating it'
$env:TYPORA_THEME_DIR = $themes

if ((Invoke-Script $install) -ne 0) { Fail 'install before uninstall failed' }
if ((Invoke-Script $uninstall) -ne 0) { Fail 'A7 uninstall failed' }
foreach ($item in @('blue-topaz.css', 'blue-topaz-dark.css', 'blue-topaz')) {
    if (Test-Path -LiteralPath (Join-Path $themes $item)) { Fail "A7 $item survived uninstall" }
}
Pass 'A7 uninstall removes the three shipped items'

foreach ($item in @('blue-topaz.user.css', 'base.user.css')) {
    if (-not (Test-Path -LiteralPath (Join-Path $themes $item))) { Fail "A8 uninstall deleted $item" }
}
Pass 'A8 uninstall leaves user css alone'

Invoke-Script $uninstall | Out-Null
if ($script:LastOutput -notlike '*Nothing to remove*') { Fail 'A9 second uninstall did not report a clean folder' }
Pass 'A9 uninstall is repeatable'

Remove-Item -LiteralPath $themes -Recurse -Force -ErrorAction SilentlyContinue
Remove-Item -LiteralPath $outside -Recurse -Force -ErrorAction SilentlyContinue
Write-Host ''
Write-Host 'all assertions passed'
