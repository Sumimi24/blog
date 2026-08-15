param(
    [Parameter(Mandatory = $true)]
    [string]$VaultPath,

    [string]$BlogFolder = "",

    [switch]$PublishAll
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($BlogFolder)) {
    $BlogFolder = ([char]0x4E0A) + ([char]0x4F20) + "MD" + ([char]0x6587) + ([char]0x672C) + ([char]0x5E93)
}

$workspaceRoot = Split-Path -Parent $PSScriptRoot
$vaultRoot = (Resolve-Path -LiteralPath $VaultPath).Path
$blogRoot = Join-Path $vaultRoot $BlogFolder
$postOutputRoot = Join-Path $workspaceRoot "source\_posts\obsidian"
$assetOutputRoot = Join-Path $workspaceRoot "source\img\obsidian"

if (-not (Test-Path -LiteralPath $blogRoot -PathType Container)) {
    throw "Obsidian publish folder not found: $blogRoot"
}

New-Item -ItemType Directory -Force -Path $postOutputRoot, $assetOutputRoot | Out-Null

$assetExtensions = @(".png", ".jpg", ".jpeg", ".gif", ".webp", ".svg", ".avif")
$assetIndex = @{}

Get-ChildItem -LiteralPath $vaultRoot -File -Recurse | Where-Object {
    $assetExtensions -contains $_.Extension.ToLowerInvariant()
} | ForEach-Object {
    $key = $_.Name.ToLowerInvariant()
    if (-not $assetIndex.ContainsKey($key)) {
        $assetIndex[$key] = @()
    }
    $assetIndex[$key] += $_.FullName
}

function ConvertTo-SafeName {
    param([string]$Name)

    $safe = $Name -replace '[<>:"/\\|?*]', '-'
    $safe = $safe -replace '\s+', '-'
    $safe = $safe.Trim('.', '-', ' ')
    if ([string]::IsNullOrWhiteSpace($safe)) {
        return "note"
    }
    return $safe
}

function Test-ShouldPublish {
    param([string]$Content)

    if ($PublishAll) {
        return $true
    }

    $frontMatter = [regex]::Match($Content, '(?s)^---\s*\r?\n(?<yaml>.*?)\r?\n---')
    if (-not $frontMatter.Success) {
        return $false
    }

    return [regex]::IsMatch(
        $frontMatter.Groups['yaml'].Value,
        '(?im)^publish\s*:\s*(true|yes|1)\s*$'
    )
}

function Add-HexoFrontMatter {
    param(
        [string]$Content,
        [System.IO.FileInfo]$File
    )

    $frontMatter = [regex]::Match($Content, '(?s)^---\s*\r?\n(?<yaml>.*?)\r?\n---\s*\r?\n?')
    $defaultDate = $File.LastWriteTime.ToString('yyyy-MM-dd HH:mm:ss')
    $escapedTitle = $File.BaseName.Replace("'", "''")

    if ($frontMatter.Success) {
        $yaml = $frontMatter.Groups['yaml'].Value.TrimEnd()
        $body = $Content.Substring($frontMatter.Length)
        $additions = @()

        if (-not [regex]::IsMatch($yaml, '(?im)^title\s*:')) {
            $additions += "title: '$escapedTitle'"
        }
        if (-not [regex]::IsMatch($yaml, '(?im)^date\s*:')) {
            $additions += "date: $defaultDate"
        }
        if (-not [regex]::IsMatch($yaml, '(?im)^categories\s*:')) {
            $additions += "categories:`n  - Notes"
        }
        if (-not [regex]::IsMatch($yaml, '(?im)^tags\s*:')) {
            $additions += "tags:`n  - Obsidian"
        }

        if ($additions.Count -gt 0) {
            $yaml += "`n" + ($additions -join "`n")
        }

        return "---`n$yaml`n---`n`n$body"
    }

    return @"
---
title: '$escapedTitle'
date: $defaultDate
categories:
  - Notes
tags:
  - Obsidian
publish: true
---

$Content
"@
}

function Find-Asset {
    param(
        [string]$Reference,
        [string]$NoteDirectory
    )

    $cleanReference = $Reference.Trim().Trim('<', '>') -replace '/', '\'
    $nearNote = Join-Path $NoteDirectory $cleanReference
    if (Test-Path -LiteralPath $nearNote -PathType Leaf) {
        return (Resolve-Path -LiteralPath $nearNote).Path
    }

    $fromVaultRoot = Join-Path $vaultRoot $cleanReference
    if (Test-Path -LiteralPath $fromVaultRoot -PathType Leaf) {
        return (Resolve-Path -LiteralPath $fromVaultRoot).Path
    }

    $fileName = [System.IO.Path]::GetFileName($cleanReference).ToLowerInvariant()
    if ($assetIndex.ContainsKey($fileName)) {
        return $assetIndex[$fileName][0]
    }

    return $null
}

function Copy-PostAsset {
    param(
        [string]$Reference,
        [string]$NoteDirectory,
        [string]$PostSlug
    )

    $sourceAsset = Find-Asset -Reference $Reference -NoteDirectory $NoteDirectory
    if (-not $sourceAsset) {
        Write-Warning "Attachment not found: $Reference"
        return $null
    }

    $postAssetDirectory = Join-Path $assetOutputRoot $PostSlug
    New-Item -ItemType Directory -Force -Path $postAssetDirectory | Out-Null

    $sourceName = [System.IO.Path]::GetFileName($sourceAsset)
    $safeAssetName = ConvertTo-SafeName -Name $sourceName
    $destination = Join-Path $postAssetDirectory $safeAssetName
    Copy-Item -LiteralPath $sourceAsset -Destination $destination -Force

    $urlName = [Uri]::EscapeDataString($safeAssetName)
    return "/img/obsidian/$PostSlug/$urlName"
}

$publishedCount = 0
$skippedCount = 0
$utf8WithoutBom = New-Object System.Text.UTF8Encoding($false)

Get-ChildItem -LiteralPath $blogRoot -Filter '*.md' -File -Recurse | ForEach-Object {
    $note = $_
    $content = [System.IO.File]::ReadAllText($note.FullName)

    if (-not (Test-ShouldPublish -Content $content)) {
        $skippedCount++
        return
    }

    $relativePath = $note.FullName.Substring($blogRoot.Length).TrimStart('\', '/')
    $relativeDirectory = Split-Path $relativePath -Parent
    $destinationDirectory = if ([string]::IsNullOrWhiteSpace($relativeDirectory)) {
        $postOutputRoot
    } else {
        Join-Path $postOutputRoot $relativeDirectory
    }
    New-Item -ItemType Directory -Force -Path $destinationDirectory | Out-Null

    $postSlug = ConvertTo-SafeName -Name $note.BaseName
    $content = Add-HexoFrontMatter -Content $content -File $note

    $obsidianEmbedPattern = '!\[\[(?<path>[^\]|#]+)(?:\|(?<alt>[^\]]+))?\]\]'
    $content = [regex]::Replace($content, $obsidianEmbedPattern, {
        param($match)
        $reference = $match.Groups['path'].Value
        $assetUrl = Copy-PostAsset -Reference $reference -NoteDirectory $note.DirectoryName -PostSlug $postSlug
        if (-not $assetUrl) {
            return $match.Value
        }
        $alt = $match.Groups['alt'].Value
        if ([string]::IsNullOrWhiteSpace($alt)) {
            $alt = [System.IO.Path]::GetFileNameWithoutExtension($reference)
        }
        return "![$alt]($assetUrl)"
    })

    $markdownImagePattern = '!\[(?<alt>[^\]]*)\]\((?<path>[^\)]+)\)'
    $content = [regex]::Replace($content, $markdownImagePattern, {
        param($match)
        $reference = $match.Groups['path'].Value.Trim().Trim('<', '>')
        if ($reference -match '^(https?:|data:|/)') {
            return $match.Value
        }
        $assetUrl = Copy-PostAsset -Reference $reference -NoteDirectory $note.DirectoryName -PostSlug $postSlug
        if (-not $assetUrl) {
            return $match.Value
        }
        return "![$($match.Groups['alt'].Value)]($assetUrl)"
    })

    $destinationFile = Join-Path $destinationDirectory $note.Name
    [System.IO.File]::WriteAllText($destinationFile, $content, $utf8WithoutBom)
    Write-Host "Imported: $relativePath"
    $publishedCount++
}

Write-Host ""
Write-Host "Obsidian import complete: imported $publishedCount, skipped $skippedCount."
Write-Host "Next: run npm run dev, review the site, then commit and push."
