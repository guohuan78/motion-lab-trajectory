[CmdletBinding()]
param(
    [string]$Root = $PSScriptRoot
)

$ErrorActionPreference = "Stop"

$templatePath = Join-Path $Root "index.template.html"
$stylesPath = Join-Path $Root "styles.css"
$appPath = Join-Path $Root "app.js"
$outputPath = Join-Path $Root "index.html"

$template = [System.IO.File]::ReadAllText($templatePath)
$styles = [System.IO.File]::ReadAllText($stylesPath)
$app = [System.IO.File]::ReadAllText($appPath)

if ($styles.Contains("</style")) {
    throw "styles.css contains a closing style tag and cannot be inlined safely."
}
if ($app.Contains("</script")) {
    throw "app.js contains a closing script tag and cannot be inlined safely."
}
if (-not $template.Contains("<!-- @inline-css -->")) {
    throw "Missing CSS placeholder in index.template.html."
}
if (-not $template.Contains("<!-- @inline-app -->")) {
    throw "Missing app placeholder in index.template.html."
}

$output = $template.Replace(
    "<!-- @inline-css -->",
    "<style>`n$styles`n    </style>"
).Replace(
    "<!-- @inline-app -->",
    "<script>`n$app`n    </script>"
)

$utf8WithoutBom = [System.Text.UTF8Encoding]::new($false)
[System.IO.File]::WriteAllText($outputPath, $output, $utf8WithoutBom)

Write-Host "Built single-file page: $outputPath"
Write-Host "Size: $([System.Text.Encoding]::UTF8.GetByteCount($output)) bytes"
