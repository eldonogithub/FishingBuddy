param([Parameter(Mandatory=$true)][string]$OutputPath)
$ErrorActionPreference = 'Stop'
$repo = Split-Path $PSScriptRoot -Parent
$destination = [IO.Path]::GetFullPath($OutputPath)
if (Test-Path -LiteralPath $destination) { throw 'Choose a new output directory.' }
New-Item -ItemType Directory -Path $destination | Out-Null
foreach ($relative in (git -C $repo ls-files)) {
    if ($relative -match '^(scripts/|tests/|README|ELDON)' -or $relative -match '^FishingBuddy_(TBC|Vanilla|Wrath)\.toc$') { continue }
    $target = Join-Path $destination ($relative.Replace('FishingBuddy','FishingBuddyEldon'))
    New-Item -ItemType Directory -Path (Split-Path $target -Parent) -Force | Out-Null
    if ([IO.Path]::GetExtension($relative) -in '.lua','.xml','.toc','.txt') {
        $content = [IO.File]::ReadAllText((Join-Path $repo $relative)).Replace('FishingBuddy','FishingBuddyEldon')
        if ($relative -eq 'FishingBuddy.toc') {
            $content = $content -replace '(?m)^## Title:.*','## Title: Fishing Buddy Eldon (Forever)'
            $content = $content -replace '(?m)^## Version:.*','## Version: 1.0.11-Eldon.1'
            $content = $content -replace '(?m)^## (X-Curse-Project-ID|X-Wago-ID):.*\r?\n',''
        }
        if ($relative -match '^locale/') { $content = $content.Replace('NAME = "Fishing Buddy"','NAME = "Fishing Buddy Eldon"') }
        [IO.File]::WriteAllText($target, $content, [Text.UTF8Encoding]::new($false))
    } else { Copy-Item -LiteralPath (Join-Path $repo $relative) -Destination $target }
}
Write-Output $destination
