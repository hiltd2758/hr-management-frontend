# PowerShell script to add Google Fonts (Nunito) to all HTML files
$workingDirectory = Get-Location
Write-Host "Working directory: $workingDirectory"

# Google Fonts links to add
$googleFontsLinks = @"
	<link rel="preconnect" href="https://fonts.googleapis.com">
	<link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
	<link href="https://fonts.googleapis.com/css2?family=Nunito:ital,wght@0,200..1000;1,200..1000&display=swap"
		rel="stylesheet">

"@

# Get all HTML files in the current directory
$htmlFiles = Get-ChildItem -Path "." -Filter "*.html" -File

Write-Host "Found $($htmlFiles.Count) HTML files"

foreach ($file in $htmlFiles) {
    Write-Host "Processing: $($file.Name)"
    
    # Read the file content
    $content = Get-Content -Path $file.FullName -Raw -Encoding UTF8
    
    # Check if the file already has Google Fonts for Nunito
    if ($content -match "fonts\.googleapis\.com.*Nunito") {
        Write-Host "  - Already has Nunito font, skipping"
        continue
    }
    
    # Find the title tag and insert Google Fonts links after it
    if ($content -match "(<title>.*?</title>)") {
        $titleTag = $matches[1]
        $newContent = $content -replace "($titleTag)", "`$1`n`n$googleFontsLinks"
        
        # Write the updated content back to the file
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8 -NoNewline
        Write-Host "  - Added Google Fonts links"
    } else {
        Write-Host "  - Could not find title tag, skipping"
    }
}

Write-Host "Font addition completed!"
