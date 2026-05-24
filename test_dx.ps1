Add-Type -AssemblyName System.Drawing

$scratchDir = 'c:/graduation-project-nudge-main/scratch_alignment'

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

# Run the 4 combinations with calculated dx and dy
Create-Composite "assets/avatar/characters/character_0.png" "assets/avatar/simple_outfits/outfit_1.png" 1.09 -21.5 29 "aligned_c0_o1_dx.png"
Create-Composite "assets/avatar/characters/character_0.png" "assets/avatar/simple_outfits/outfit_2.png" 0.96 11.7 73 "aligned_c0_o2_dx.png"
Create-Composite "assets/avatar/characters/character_1.png" "assets/avatar/simple_outfits/outfit_1.png" 0.95 15.8 76 "aligned_c1_o1_dx.png"
Create-Composite "assets/avatar/characters/character_1.png" "assets/avatar/simple_outfits/outfit_2.png" 0.84 44.0 115 "aligned_c1_o2_dx.png"

Write-Host "Done generating test images with dx."
