Add-Type -AssemblyName System.Drawing
$bmp1 = New-Object System.Drawing.Bitmap('assets/avatar/characters/character_0.png')
$g = [System.Drawing.Graphics]::FromImage($bmp1)
$bmp2 = New-Object System.Drawing.Bitmap('assets/avatar/simple_outfits/outfit_1.png')

# Draw the outfit shifted down by 73 pixels
$g.DrawImage($bmp2, 0, 73, 512, 768)

$g.Dispose()
$bmp2.Dispose()
$bmp1.Save('combined_shifted_73.png', [System.Drawing.Imaging.ImageFormat]::Png)
$bmp1.Dispose()
Write-Host "Saved combined_shifted_73.png"
