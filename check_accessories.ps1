Add-Type -AssemblyName System.Drawing
Get-ChildItem -Path assets/avatar/accessories/*.png | ForEach-Object {
    $bmp = New-Object System.Drawing.Bitmap($_.FullName)
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
    [PSCustomObject]@{
        Path = $_.Name
        MinX = $minX
        MaxX = $maxX
        MinY = $minY
        MaxY = $maxY
        Width = $maxX - $minX + 1
        Height = $maxY - $minY + 1
    }
} | Format-Table
