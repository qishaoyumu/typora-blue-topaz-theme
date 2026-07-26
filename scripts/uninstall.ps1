<#
    Blue Topaz for Typora - uninstall

      powershell -ExecutionPolicy ByPass -c "irm https://raw.githubusercontent.com/qishaoyumu/typora-blue-topaz-theme/master/scripts/uninstall.ps1 | iex"

    Removes only the three items the theme ships. Your own blue-topaz.user.css
    and base.user.css are left alone, and so is every other theme.

    Environment:
      TYPORA_THEME_DIR  uninstall from this existing directory instead of probing
#>

$ErrorActionPreference = 'Stop'

$Repo = 'qishaoyumu/typora-blue-topaz-theme'
$ManualUrl = "https://github.com/$Repo#manual-install"

# The three items the release archive installs. Unlike install.ps1, which reads
# the entry list out of the archive, uninstall has no archive to read, so this
# list is the contract: renaming any of them breaks installation anyway.
$Targets = @('blue-topaz.css', 'blue-topaz-dark.css', 'blue-topaz')

if ($PSVersionTable.PSVersion.Major -lt 5) {
    throw "PowerShell 5.1 or later is required. Follow the manual steps instead: $ManualUrl"
}

# Same probe as install.ps1; kept as a copy so each script stays a single file
# that can be piped straight into PowerShell.
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
Open Preferences > Appearance > Open Theme Folder to see the real path and pass it in:
  `$env:TYPORA_THEME_DIR = 'C:\your\path'
"@
}

function Test-IsLink {
    param([string]$Path)
    if (-not (Test-Path -LiteralPath $Path)) { return $false }
    $item = Get-Item -LiteralPath $Path -Force
    return (($item.Attributes -band [IO.FileAttributes]::ReparsePoint) -eq [IO.FileAttributes]::ReparsePoint)
}

$themeDir = Resolve-ThemeDir
Write-Host "Theme folder: $themeDir"

# Guard pass before removing anything.
foreach ($target in $Targets) {
    $path = Join-Path $themeDir $target
    if (Test-IsLink -Path $path) {
        throw @"
"$path" is a symlink or junction, which usually means a development setup.
Refusing to remove it. Delete the link yourself if that is what you want.
"@
    }
}

$removed = 0
foreach ($target in $Targets) {
    $path = Join-Path $themeDir $target
    if (Test-Path -LiteralPath $path) {
        Remove-Item -LiteralPath $path -Recurse -Force
        Write-Host "  removed $target"
        $removed++
    }
}

if ($removed -eq 0) {
    Write-Host ''
    Write-Host 'Nothing to remove: Blue Topaz is not installed in that folder.'
    return
}

Write-Host @'

Blue Topaz has been removed.

If Typora is still set to Blue Topaz, pick another theme from the Themes menu,
then quit Typora completely and reopen it.

Any blue-topaz.user.css or base.user.css you wrote was left in place.
'@
