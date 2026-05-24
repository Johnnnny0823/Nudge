Add-Type -AssemblyName System.Drawing

function Find-KeyPoints($path, $isCharacter) {
    $bmp = New-Object System.Drawing.Bitmap($path)
    $w = $bmp.Width
    $h = $bmp.Height
    
    # We want to scan the center column (X = 250 to 262) to find vertical features
    $centerX = 256
    
    $topOutfit = -1
    $bottomOutfit = -1
    $waistOutfit = -1
    
    $topCharHair = -1
    $topCharCollar = -1
    $waistChar = -1
    $bottomCharFeet = -1
    
    # Scanning loop
    for ($y = 0; $y -lt $h; $y++) {
        # Check center pixel transparency/color
        $pixel = $bmp.GetPixel($centerX, $y)
        $a = $pixel.A
        $r = $pixel.R
        $g = $pixel.G
        $b = $pixel.B
        
        if ($a -gt 10) {
            if ($isCharacter) {
                # Character detection
                if ($topCharHair -eq -1) {
                    $topCharHair = $y
                }
                
                # Check for white shirt collar: high RGB, close to white
                if ($topCharCollar -eq -1 -and $r -gt 220 -and $g -gt 220 -and $b -gt 220) {
                    $topCharCollar = $y
                }
                
                # Check for boundary between white shirt and grey shorts
                # White shirt is r>200, g>200, b>200. Grey shorts are around r~120, g~120, b~120
                if ($topCharCollar -ne -1 -and $waistChar -eq -1 -and $r -lt 160 -and $g -lt 160 -and $b -lt 160) {
                    # Make sure it's not skin tone (skin tone has R > G > B, e.g. R=247, G=214, B=191)
                    if ($r -lt 200) {
                        $waistChar = $y
                    }
                }
                
                # Bottom feet is the last non-transparent pixel in this column or overall
                $bottomCharFeet = $y
            } else {
                # Outfit detection
                if ($topOutfit -eq -1) {
                    $topOutfit = $y
                }
                # Check for boundary between shirt (light purple/pink, e.g. R~199, G~166, B~247) 
                # and pants (dark purple, R~80, G~60, B~120)
                # Let's check when red channel drops significantly
                if ($topOutfit -ne -1 -and $waistOutfit -eq -1 -and $y -gt ($topOutfit + 50) -and $r -lt 120) {
                    $waistOutfit = $y
                }
                $bottomOutfit = $y
            }
        }
    }
    
    # If waist wasn't found by center, scan a wider area
    if ($isCharacter -and $waistChar -eq -1) {
        # Fallback search for waist: find transition from white to grey
        for ($y = 200; $y -lt 500; $y++) {
            $p = $bmp.GetPixel($centerX, $y)
            if ($p.R -lt 160 -and $p.G -lt 160 -and $p.B -lt 160 -and $p.A -gt 200) {
                $waistChar = $y
                break
            }
        }
    }
    
    $bmp.Dispose()
    
    if ($isCharacter) {
        return [PSCustomObject]@{
            Path = (Split-Path $path -Leaf)
            HairTop = $topCharHair
            CollarTop = $topCharCollar
            Waist = $waistChar
            FeetBottom = $bottomCharFeet
        }
    } else {
        return [PSCustomObject]@{
            Path = (Split-Path $path -Leaf)
            CollarTop = $topOutfit
            Waist = $waistOutfit
            ShoesBottom = $bottomOutfit
        }
    }
}

Write-Host "--- Base Characters ---"
Find-KeyPoints "assets/avatar/characters/character_0.png" $true | Format-List
Find-KeyPoints "assets/avatar/characters/character_1.png" $true | Format-List

Write-Host "--- Outfits ---"
Find-KeyPoints "assets/avatar/simple_outfits/outfit_1.png" $false | Format-List
Find-KeyPoints "assets/avatar/simple_outfits/outfit_2.png" $false | Format-List
