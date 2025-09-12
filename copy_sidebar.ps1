# Script to copy sidebar from index.html to all other HTML files
$directory = "."
$indexFile = Join-Path $directory "index.html"

# Read the sidebar content from index.html
$indexContent = Get-Content $indexFile -Raw

# Extract sidebar section from index.html
$sidebarStart = $indexContent.IndexOf('<div class="sidebar" id="sidebar">')
$sidebarEnd = $indexContent.IndexOf('</div>', $indexContent.IndexOf('</div>', $indexContent.IndexOf('</div>', $sidebarStart) + 1) + 1) + 6
$newSidebar = $indexContent.Substring($sidebarStart, $sidebarEnd - $sidebarStart)

Write-Host "Extracted sidebar from index.html"

# Get all HTML files except index.html
$htmlFiles = Get-ChildItem -Path $directory -Filter "*.html" | Where-Object { $_.Name -ne "index.html" -and $_.Name -ne "login.html" -and $_.Name -ne "register.html" }

$updatedCount = 0
$notFoundCount = 0

foreach ($file in $htmlFiles) {
    $fileName = $file.Name
    $content = Get-Content $file.FullName -Raw
    
    # Find and replace the sidebar in each file
    $currentSidebarStart = $content.IndexOf('<div class="sidebar"')
    if ($currentSidebarStart -ge 0) {
        $currentSidebarEnd = $content.IndexOf('</div>', $content.IndexOf('</div>', $content.IndexOf('</div>', $currentSidebarStart) + 1) + 1) + 6
        
        # Replace the old sidebar with the new one
        $beforeSidebar = $content.Substring(0, $currentSidebarStart)
        $afterSidebar = $content.Substring($currentSidebarEnd)
        $newContent = $beforeSidebar + $newSidebar + $afterSidebar
        
        # Write the updated content back to the file
        Set-Content -Path $file.FullName -Value $newContent -Encoding UTF8
        Write-Host "Updated sidebar in $fileName"
        $updatedCount++
    } else {
        Write-Host "Sidebar not found in $fileName"
        $notFoundCount++
    }
}

Write-Host ""
Write-Host "=== Summary ==="
Write-Host "Files updated: $updatedCount"
Write-Host "Files without sidebar: $notFoundCount"
Write-Host "Sidebar copy completed!"
