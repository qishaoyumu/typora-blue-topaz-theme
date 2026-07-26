<#
    Blue Topaz for Typora - install / update

      powershell -ExecutionPolicy ByPass -c "irm https://raw.githubusercontent.com/qishaoyumu/typora-blue-topaz-theme/master/scripts/install.ps1 | iex"

    Running this again updates an existing installation; it is safe to repeat.
    For macOS, Linux, Git Bash, or WSL use scripts/install.sh instead.

    Environment:
      TYPORA_THEME_DIR  install into this existing directory instead of probing

    Errors are raised as terminating errors, so the command reports a non-zero
    exit code without closing an interactive PowerShell session.
#>

$ErrorActionPreference = 'Stop'

$Repo = 'qishaoyumu/typora-blue-topaz-theme'
$ZipUrl = "https://github.com/$Repo/releases/latest/download/blue-topaz-typora.zip"
$ManualUrl = "https://github.com/$Repo#manual-install"

if ($PSVersionTable.PSVersion.Major -lt 5) {
    throw "PowerShell 5.1 or later is required. Follow the manual steps instead: $ManualUrl"
}

try {
    [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
}
catch {
    # Newer .NET negotiates TLS on its own; nothing to do here.
}

# Only ever returns a directory that already exists: creating one would look
# like success while Typora keeps reading somewhere else.
function Resolve-ThemeDir {
    if ($env:TYPORA_THEME_DIR) {
        if (-not (Test-Path -LiteralPath $env:TYPORA_THEME_DIR -PathType Container)) {
            throw "TYPORA_THEME_DIR is set to `"$($env:TYPORA_THEME_DIR)`", which is not an existing directory."
        }
        return (Get-Item -LiteralPath $env:TYPORA_THEME_DIR).FullName
    }

    if (-not $env:APPDATA) {
        throw "APPDATA is not set, so the Typora theme folder cannot be located. Set TYPORA_THEME_DIR to your theme folder and run again."
    }

    $candidate = Join-Path $env:APPDATA 'Typora\themes'
    if (Test-Path -LiteralPath $candidate -PathType Container) {
        return (Get-Item -LiteralPath $candidate).FullName
    }

    throw @"
Could not find the Typora theme folder. Looked in:
  $candidate
Run Typora once so it creates the folder, or open Preferences > Appearance > Open Theme Folder
to see the real path and pass it in: `$env:TYPORA_THEME_DIR = 'C:\your\path'
"@
}

function Test-IsLink {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    $item = Get-Item -LiteralPath $Path -Force
    return (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq [IO.FileAttributes]::ReparsePoint)
}

# Best effort only: the released tag lives in the redirect target. Never let a
# missing version string stop an install.
function Get-ReleaseTag {
    param([string]$Url)
    try {
        $request = [Net.WebRequest]::Create($Url)
        $request.Method = 'HEAD'
        $request.AllowAutoRedirect = $false
        $response = $request.GetResponse()
        $location = $response.Headers['Location']
        $response.Close()
        if ($location -match '/download/([^/]+)/') { return $Matches[1] }
    }
    catch {
        return $null
    }
    return $null
}

$themeDir = Resolve-ThemeDir
$tempDir = Join-Path ([IO.Path]::GetTempPath()) ('blue-topaz-' + [Guid]::NewGuid().ToString('N'))
New-Item -ItemType Directory -Path $tempDir | Out-Null

try {
    Write-Host "Theme folder: $themeDir"
    Write-Host 'Downloading the latest release...'

    $zipPath = Join-Path $tempDir 'theme.zip'
    try {
        Invoke-WebRequest -Uri $ZipUrl -OutFile $zipPath -UseBasicParsing
    }
    catch {
        throw "Download failed. If your network cannot reach GitHub, follow the manual steps: $ManualUrl"
    }

    $version = Get-ReleaseTag -Url $ZipUrl

    $payloadDir = Join-Path $tempDir 'payload'
    Expand-Archive -LiteralPath $zipPath -DestinationPath $payloadDir -Force

    $entries = @(Get-ChildItem -LiteralPath $payloadDir -Force)
    if ($entries.Count -eq 0) { throw 'The downloaded archive was empty.' }

    # Guard pass: nothing is written until every entry has been checked, so an
    # abort here leaves the theme folder exactly as it was.
    foreach ($entry in $entries) {
        $target = Join-Path $themeDir $entry.Name
        if (Test-IsLink -Path $target) {
            throw @"
"$target" is a symlink or junction, which usually means a development setup.
Refusing to overwrite it, because copying through the link would rewrite the file it points at.
Remove the link yourself, or install elsewhere with `$env:TYPORA_THEME_DIR.
"@
        }
    }

    foreach ($entry in $entries) {
        $target = Join-Path $themeDir $entry.Name
        if (Test-Path -LiteralPath $target) {
            Remove-Item -LiteralPath $target -Recurse -Force
        }
        Copy-Item -LiteralPath $entry.FullName -Destination $themeDir -Recurse -Force
        Write-Host "  installed $($entry.Name)"
    }

    if ($version) {
        Write-Host ''
        Write-Host "Blue Topaz $version is installed."
    }
    else {
        Write-Host ''
        Write-Host 'Blue Topaz is installed.'
    }

    Write-Host @'

Next steps:
  1. Quit Typora completely (File > Exit, not just the window).
  2. Reopen it and pick "Blue Topaz" or "Blue Topaz Dark" from the Themes menu.

If the themes do not show up, compare the theme folder printed above with the
one Typora opens from Preferences > Appearance > Open Theme Folder.

Your own tweaks belong in blue-topaz.user.css or base.user.css; this script
never touches those files.
'@
}
finally {
    Remove-Item -LiteralPath $tempDir -Recurse -Force -ErrorAction SilentlyContinue
}
