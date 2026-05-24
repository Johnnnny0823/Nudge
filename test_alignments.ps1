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
    
    # Draw character
    $g.DrawImage($charBmp, 0, 0, 512, 768)
    
    # Draw outfit scaled and offset
    # When drawing, DrawImage draws in the coordinate system of the graphics context.
    # We want to scale the image by $scale, and offset it by $dx, $dy.
    # The scaled width and height are 512 * $scale, 768 * $scale.
    # The center of the original image is at (256, 384).
    # When scaled, the new top-left corner should be positioned such that after translation it matches our desired offset.
    # If we want the top-left of the outfit to be at (dx, dy) when scale = 1, then for scale S:
    # We want the collar (which was at Y_collar) to map to Y_collar_target = Y_collar * S + dy_canvas? No!
    # Wait, the formula we solved:
    # Y_target = Y_original * S + dy
    # This means the canvas coordinate Y_target is equal to Y_original * S + dy.
    # If the canvas coordinate Y_target is Y_original * S + dy, then the top-left corner (0,0) of the original image
    # will map to Y = 0 * S + dy = dy, and X = 0 * S + dx = dx.
    # Yes! So the top-left of the destination rectangle should be at ($dx, $dy)!
    # And the destination width and height should be 512 * $scale and 768 * $scale.
    # Let's double check this!
    # If the destination rect starts at (dx, dy) and has size (512*S, 768*S):
    # A point (X_orig, Y_orig) in the original image will map to:
    # X_dest = dx + X_orig * S
    # Y_dest = dy + Y_orig * S
    # This matches our formula EXACTLY!
    # So the top-left corner of the destination rectangle is simply (dx, dy).
    
    $w = 512 * $scale
    $h = 768 * $scale
    
    $g.DrawImage($outfitBmp, [float]$dx, [float]$dy, [float]$w, [float]$h)
    
    $g.Dispose()
    $charBmp.Dispose()
    $outfitBmp.Dispose()
    
    $canvas.Save("$scratchDir/$outName", [System.Drawing.Imaging.ImageFormat]::Png)
    $canvas.Dispose()
}

# Run the 4 combinations
Create-Composite "assets/avatar/characters/character_0.png" "assets/avatar/simple_outfits/outfit_1.png" 1.09 0 29 "aligned_c0_o1.png"
Create-Composite "assets/avatar/characters/character_0.png" "assets/avatar/simple_outfits/outfit_2.png" 0.96 0 73 "aligned_c0_o2.png"
Create-Composite "assets/avatar/characters/character_1.png" "assets/avatar/simple_outfits/outfit_1.png" 0.95 0 76 "aligned_c1_o1.png"
Create-Composite "assets/avatar/characters/character_1.png" "assets/avatar/simple_outfits/outfit_2.png" 0.84 0 115 "aligned_c1_o2.png"

Write-Host "Done generating aligned test images."
