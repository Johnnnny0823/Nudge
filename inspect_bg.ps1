Add-Type -AssemblyName System.Drawing

$newPath = "C:\Users\xnikz\.gemini\antigravity-ide\brain\593eef07-5ab4-4ee4-8409-a1113641a341\character_1_new_1779470671146.png"
$bmp = New-Object System.Drawing.Bitmap($newPath)

# Check corner pixels
$c1 = $bmp.GetPixel(0, 0)
$c2 = $bmp.GetPixel($bmp.Width - 1, 0)
$c3 = $bmp.GetPixel(0, $bmp.Height - 1)
$c4 = $bmp.GetPixel($bmp.Width - 1, $bmp.Height - 1)

Write-Host "Corner pixels (RGBA):"
Write-Host "Top-Left: R=$($c1.R), G=$($c1.G), B=$($c1.B), A=$($c1.A)"
Write-Host "Top-Right: R=$($c2.R), G=$($c2.G), B=$($c2.B), A=$($c2.A)"
Write-Host "Bottom-Left: R=$($c3.R), G=$($c3.G), B=$($c3.B), A=$($c3.A)"
Write-Host "Bottom-Right: R=$($c4.R), G=$($c4.G), B=$($c4.B), A=$($c4.A)"

# Let's count some color distributions to see what the background is.
# We'll check the top 10 rows and see if they are uniform.
$isWhiteBg = $true
for ($y = 0; $y -lt 10; $y++) {
    for ($x = 0; $x -lt $bmp.Width; $x++) {
        $p = $bmp.GetPixel($x, $y)
        # If it's not close to white (e.g. RGB > 240)
        if ($p.R -lt 240 -or $p.G -lt 240 -or $p.B -lt 240) {
            $isWhiteBg = $false
            break
        }
    }
    if (-not $isWhiteBg) { break }
}

Write-Host "Is the top 10 rows background white? $isWhiteBg"

$bmp.Dispose()
