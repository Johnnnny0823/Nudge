Add-Type -AssemblyName System.Drawing

function Get-BoundingBox($path) {
    $bmp = New-Object System.Drawing.Bitmap($path)
    $w = $bmp.Width
    $h = $bmp.Height
    $minX = $w; $maxX = 0; $minY = $h; $maxY = 0
    
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $pixel = $bmp.GetPixel($x, $y)
            # Use alpha threshold of 10 to ignore semi-transparent edges
            if ($pixel.A -gt 10) {
                if ($x -lt $minX) { $minX = $x }
                if ($x -gt $maxX) { $maxX = $x }
                if ($y -lt $minY) { $minY = $y }
                if ($y -gt $maxY) { $maxY = $y }
            }
        }
    }
    $bmp.Dispose()
    return [PSCustomObject]@{
        Path = (Split-Path $path -Leaf)
        Width = $w
        Height = $h
        MinX = $minX
        MaxX = $maxX
        MinY = $minY
        MaxY = $maxY
        ContentWidth = ($maxX - $minX + 1)
        ContentHeight = ($maxY - $minY + 1)
    }
}

$orig = Get-BoundingBox "assets/avatar/characters/character_1.png"
$new = Get-BoundingBox "C:\Users\xnikz\.gemini\antigravity-ide\brain\593eef07-5ab4-4ee4-8409-a1113641a341\character_1_new_1779470671146.png"

$orig | Format-List
$new | Format-List
