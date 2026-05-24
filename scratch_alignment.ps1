Add-Type -AssemblyName System.Drawing

$scratchDir = 'c:/graduation-project-nudge-main/scratch_alignment'
if (-not (Test-Path $scratchDir)) {
    New-Item -ItemType Directory -Path $scratchDir
}

function Create-Composite($charPath, $outfitPath, $scale, $dx, $dy, $outName) {
    $charBmp = New-Object System.Drawing.Bitmap($charPath)
    $outfitBmp = New-Object System.Drawing.Bitmap($outfitPath)
    
    # Create a blank canvas of the same size to draw both
    $canvas = New-Object System.Drawing.Bitmap(512, 768)
    $g = [System.Drawing.Graphics]::FromImage($canvas)
    
    # Clear to a light blue/cyan color to simulate App background
    $g.Clear([System.Drawing.Color]::FromArgb(255, 102, 213, 229))
    
    # Draw character at original scale
    $g.DrawImage($charBmp, 0, 0, 512, 768)
    
    # Draw outfit scaled and offset
    $w = 512 * $scale
    $h = 768 * $scale
    $x = 256 * (1 - $scale) + $dx
    $y = 384 * (1 - $scale) + $dy
    
    $g.DrawImage($outfitBmp, [float]$x, [float]$y, [float]$w, [float]$h)
    
    $g.Dispose()
    $charBmp.Dispose()
    $outfitBmp.Dispose()
    
    $canvas.Save("$scratchDir/$outName", [System.Drawing.Imaging.ImageFormat]::Png)
    $canvas.Dispose()
}

# Let's test a few combinations for character_0 and outfit_1
# We believe scale is around 1.25 to 1.35, and dy is around 80 to 120
foreach ($s in @(1.28, 1.30, 1.32)) {
    foreach ($dy in @(95, 105, 115)) {
        $name = "c0_o1_s${s}_dy${dy}.png"
        Create-Composite "assets/avatar/characters/character_0.png" "assets/avatar/simple_outfits/outfit_1.png" $s 0 $dy $name
    }
}

# Let's also test character_1 (female) and outfit_1
foreach ($s in @(1.15, 1.20, 1.25)) {
    foreach ($dy in @(70, 80, 90)) {
        $name = "c1_o1_s${s}_dy${dy}.png"
        Create-Composite "assets/avatar/characters/character_1.png" "assets/avatar/simple_outfits/outfit_1.png" $s 0 $dy $name
    }
}

Write-Host "Done generating test composites in $scratchDir"
