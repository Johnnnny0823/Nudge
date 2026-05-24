Add-Type -AssemblyName System.Drawing

$scratchDir = 'c:/graduation-project-nudge-main/scratch_alignment'
if (-not (Test-Path $scratchDir)) {
    New-Item -ItemType Directory -Path $scratchDir
}

function Create-Composite($charPath, $outfitPath, $scale, $dx, $dy, $outName) {
    $charBmp = New-Object System.Drawing.Bitmap($charPath)
    $outfitBmp = New-Object System.Drawing.Bitmap($outfitPath)
    
    $canvas = New-Object System.Drawing.Bitmap(512, 768)
    $g = [System.Drawing.Graphics]::FromImage($canvas)
    $g.Clear([System.Drawing.Color]::FromArgb(255, 102, 213, 229))
    
    $g.DrawImage($charBmp, 0, 0, 512, 768)
    
    $w = 512 * $scale
    $h = 768 * $scale
    
    $g.DrawImage($outfitBmp, [float]$dx, [float]$dy, [float]$w, [float]$h)
    
    $g.Dispose()
    $charBmp.Dispose()
    $outfitBmp.Dispose()
    
    $canvas.Save("$scratchDir/$outName", [System.Drawing.Imaging.ImageFormat]::Png)
    $canvas.Dispose()
}

# Test the calculated coordinates for the new character (character_1.png)
Create-Composite "assets/avatar/characters/character_1.png" "assets/avatar/simple_outfits/outfit_1.png" 1.18 -46.1 123.9 "new_aligned_c1_o1.png"
Create-Composite "assets/avatar/characters/character_1.png" "assets/avatar/simple_outfits/outfit_2.png" 1.03 -7.7 174.4 "new_aligned_c1_o2.png"

Write-Host "Done generating test composites."
