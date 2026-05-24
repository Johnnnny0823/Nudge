Add-Type -AssemblyName System.Drawing

function Get-BoundingBox($path) {
    $bmp = New-Object System.Drawing.Bitmap($path)
    $w = $bmp.Width
    $h = $bmp.Height
    $minX = $w; $maxX = 0; $minY = $h; $maxY = 0
    
    for ($y = 0; $y -lt $h; $y++) {
        for ($x = 0; $x -lt $w; $x++) {
            $pixel = $bmp.GetPixel($x, $y)
            if ($pixel.A -gt 0) {
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

Get-ChildItem -Path assets/avatar/characters/*.png | ForEach-Object {
    Get-BoundingBox $_.FullName
} | Format-Table

Get-ChildItem -Path assets/avatar/simple_outfits/*.png | ForEach-Object {
    Get-BoundingBox $_.FullName
} | Format-Table
