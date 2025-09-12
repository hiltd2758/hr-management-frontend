# PowerShell script to copy header and sidebar from index.html to all HTML files
$workingDirectory = Get-Location
Write-Host "Working directory: $workingDirectory"

# Read the index.html file to extract the header and sidebar
$indexFile = "index.html"
if (-not (Test-Path $indexFile)) {
    Write-Host "Error: index.html not found!" -ForegroundColor Red
    exit
}

$indexContent = Get-Content -Path $indexFile -Raw -Encoding UTF8

# Extract the header and sidebar section from index.html using more flexible regex with single line mode
$pattern = '(?s)(<div class="main-wrapper">.*?)<div class="page-wrapper">'
if ($indexContent -match $pattern) {
    $headerAndSidebar = $matches[1]
    Write-Host "Successfully extracted header and sidebar from index.html"
} else {
    Write-Host "Error: Could not find header and sidebar pattern in index.html!" -ForegroundColor Red
    Write-Host "Trying alternative extraction method..."
    
    # Alternative method: find the positions manually
    $startPos = $indexContent.IndexOf('<div class="main-wrapper">')
    $endPos = $indexContent.IndexOf('<div class="page-wrapper">')
    
    if ($startPos -ne -1 -and $endPos -ne -1 -and $endPos -gt $startPos) {
        $headerAndSidebar = $indexContent.Substring($startPos, $endPos - $startPos)
        Write-Host "Successfully extracted header and sidebar using alternative method"
    } else {
        Write-Host "Error: Could not extract header and sidebar!" -ForegroundColor Red
        exit
    }
}

# Get all HTML files except index.html
$htmlFiles = Get-ChildItem -Path "." -Filter "*.html" -File | Where-Object { $_.Name -ne "index.html" }

Write-Host "Found $($htmlFiles.Count) HTML files to update (excluding index.html)"

foreach ($file in $htmlFiles) {
    Write-Host "Processing: $($file.Name)"
    
    # Read the file content
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    
    # Check if the file has the main-wrapper div
    if ($content -match '<div class="main-wrapper">') {
        # Find the positions manually for more reliable replacement
        $startPos = $content.IndexOf('<div class="main-wrapper">')
        $endPos = $content.IndexOf('<div class="page-wrapper">')
        
        if ($startPos -ne -1 -and $endPos -ne -1 -and $endPos -gt $startPos) {
            # Replace the section with the new header and sidebar
            $beforeSection = $content.Substring(0, $startPos)
            $afterSection = $content.Substring($endPos)
            $updatedContent = $beforeSection + $headerAndSidebar + $afterSection
            
            # Write the updated content back to the file
            Set-Content -Path $file.FullName -Value $updatedContent -Encoding UTF8 -NoNewline
            Write-Host "  - Updated header and sidebar successfully" -ForegroundColor Green
        } else {
            Write-Host "  - Could not locate sections properly, skipping" -ForegroundColor Yellow
        }
    } else {
        Write-Host "  - No main-wrapper found, skipping" -ForegroundColor Yellow
    }
}

Write-Host "Header and sidebar update completed!" -ForegroundColor Green
