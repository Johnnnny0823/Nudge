Add-Type -AssemblyName System.Drawing

$newPath = "C:\Users\xnikz\.gemini\antigravity-ide\brain\593eef07-5ab4-4ee4-8409-a1113641a341\character_1_new_1779470671146.png"
$bmp = New-Object System.Drawing.Bitmap($newPath)

# Sample border colors (every 32 pixels along top, bottom, left, right)
$samples = @()
for ($x = 0; $x -lt $bmp.Width; $x += 32) {
    $samples += $bmp.GetPixel($x, 0)
    $samples += $bmp.GetPixel($x, $bmp.Height - 1)
}
for ($y = 0; $y -lt $bmp.Height; $y += 32) {
    $samples += $bmp.GetPixel(0, $y)
    $samples += $bmp.GetPixel($bmp.Width - 1, $y)
}

# Group sample colors to find the most common background color
$colorCounts = @{}
foreach ($color in $samples) {
    $key = "$($color.R),$($color.G),$($color.B)"
    $val = 0
    if ($colorCounts.ContainsKey($key)) {
        $val = $colorCounts[$key]
    }
    $colorCounts[$key] = $val + 1
}

Write-Host "Top border color samples (R,G,B counts):"
$colorCounts.GetEnumerator() | Sort-Object Value -Descending | Select-Object -First 10

$bmp.Dispose()
