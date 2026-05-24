$code = @'
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.Collections.Generic;

public class ImageProcessor {
    public static void Process(string inputPath, string targetPath, string outputPath) {
        Bitmap input = new Bitmap(inputPath);
        int w = input.Width;
        int h = input.Height;
        
        // 1. Flood fill from borders to mark white background
        bool[,] isBg = new bool[w, h];
        Queue<Point> queue = new Queue<Point>();
        
        // Add all border pixels to queue
        for (int x = 0; x < w; x++) {
            queue.Enqueue(new Point(x, 0));
            queue.Enqueue(new Point(x, h - 1));
            isBg[x, 0] = true;
            isBg[x, h - 1] = true;
        }
        for (int y = 0; y < h; y++) {
            queue.Enqueue(new Point(0, y));
            queue.Enqueue(new Point(w - 1, y));
            isBg[0, y] = true;
            isBg[w - 1, y] = true;
        }
        
        Color whiteSeed = Color.FromArgb(255, 255, 255);
        int whiteTolerance = 60; // Safe tolerance since character is bounded by dark outlines/hair
        
        while (queue.Count > 0) {
            Point p = queue.Dequeue();
            Point[] neighbors = new Point[] {
                new Point(p.X + 1, p.Y),
                new Point(p.X - 1, p.Y),
                new Point(p.X, p.Y + 1),
                new Point(p.X, p.Y - 1)
            };
            
            foreach (Point n in neighbors) {
                if (n.X >= 0 && n.X < w && n.Y >= 0 && n.Y < h && !isBg[n.X, n.Y]) {
                    Color cNext = input.GetPixel(n.X, n.Y);
                    
                    int dr = whiteSeed.R - cNext.R;
                    int dg = whiteSeed.G - cNext.G;
                    int db = whiteSeed.B - cNext.B;
                    double dist = Math.Sqrt(dr*dr + dg*dg + db*db);
                    
                    if (dist < whiteTolerance) {
                        isBg[n.X, n.Y] = true;
                        queue.Enqueue(n);
                    }
                }
            }
        }
        
        // 2. Flood fill shadow at bottom center (to be thorough)
        Point shadowStart = new Point(512, 900);
        if (!isBg[shadowStart.X, shadowStart.Y]) {
            Color shadowSeed = input.GetPixel(shadowStart.X, shadowStart.Y);
            int shadowTolerance = 50;
            Queue<Point> shadowQueue = new Queue<Point>();
            shadowQueue.Enqueue(shadowStart);
            isBg[shadowStart.X, shadowStart.Y] = true;
            
            while (shadowQueue.Count > 0) {
                Point p = shadowQueue.Dequeue();
                Point[] neighbors = new Point[] {
                    new Point(p.X + 1, p.Y),
                    new Point(p.X - 1, p.Y),
                    new Point(p.X, p.Y + 1),
                    new Point(p.X, p.Y - 1)
                };
                
                foreach (Point n in neighbors) {
                    if (n.X >= 0 && n.X < w && n.Y >= 0 && n.Y < h && !isBg[n.X, n.Y]) {
                        Color cNext = input.GetPixel(n.X, n.Y);
                        
                        int dr = shadowSeed.R - cNext.R;
                        int dg = shadowSeed.G - cNext.G;
                        int db = shadowSeed.B - cNext.B;
                        double dist = Math.Sqrt(dr*dr + dg*dg + db*db);
                        
                        if (dist < shadowTolerance) {
                            isBg[n.X, n.Y] = true;
                            shadowQueue.Enqueue(n);
                        }
                    }
                }
            }
        }
        
        // 3. Create intermediate transparent bitmap
        Bitmap transparentBmp = new Bitmap(w, h);
        int minX = w, maxX = 0, minY = h, maxY = 0;
        
        for (int y = 0; y < h; y++) {
            for (int x = 0; x < w; x++) {
                if (isBg[x, y]) {
                    transparentBmp.SetPixel(x, y, Color.Transparent);
                } else {
                    Color c = input.GetPixel(x, y);
                    transparentBmp.SetPixel(x, y, c);
                    
                    // Track bounding box of character content (cap Y at 877 to completely ignore shadow)
                    if (y <= 877) {
                        if (x < minX) minX = x;
                        if (x > maxX) maxX = x;
                        if (y < minY) minY = y;
                        if (y > maxY) maxY = y;
                    }
                }
            }
        }
        
        int charW = maxX - minX + 1;
        int charH = maxY - minY + 1;
        Console.WriteLine("Character bounding box in generated image (shadow excluded): X=" + minX + " to " + maxX + " (W=" + charW + "), Y=" + minY + " to " + maxY + " (H=" + charH + ")");
        
        // 4. Crop character
        Bitmap cropped = new Bitmap(charW, charH);
        using (Graphics g = Graphics.FromImage(cropped)) {
            g.DrawImage(transparentBmp, new Rectangle(0, 0, charW, charH), new Rectangle(minX, minY, charW, charH), GraphicsUnit.Pixel);
        }
        
        // 5. Draw onto target canvas (512x768) at template coordinates
        // Target coordinates: MinX = 148, MaxX = 370 (W = 223), MinY = 171, MaxY = 546 (H = 376)
        int targetX = 148;
        int targetY = 171;
        int targetW = 223;
        int targetH = 376;
        
        Bitmap output = new Bitmap(512, 768);
        using (Graphics g = Graphics.FromImage(output)) {
            g.Clear(Color.Transparent);
            
            g.InterpolationMode = System.Drawing.Drawing2D.InterpolationMode.HighQualityBicubic;
            g.PixelOffsetMode = System.Drawing.Drawing2D.PixelOffsetMode.HighQuality;
            g.SmoothingMode = System.Drawing.Drawing2D.SmoothingMode.HighQuality;
            
            g.DrawImage(cropped, new Rectangle(targetX, targetY, targetW, targetH));
        }
        
        output.Save(outputPath, ImageFormat.Png);
        
        // Cleanup
        input.Dispose();
        transparentBmp.Dispose();
        cropped.Dispose();
        output.Dispose();
        Console.WriteLine("Successfully saved processed character image to: " + outputPath);
    }
}
'@

Add-Type -TypeDefinition $code -ReferencedAssemblies System.Drawing

$inputPath = "C:\Users\xnikz\.gemini\antigravity-ide\brain\593eef07-5ab4-4ee4-8409-a1113641a341\character_new_white_bg_1779470782886.png"
$outputPath = "C:\Users\xnikz\.gemini\antigravity-ide\brain\593eef07-5ab4-4ee4-8409-a1113641a341\processed_character_1.png"

[ImageProcessor]::Process($inputPath, "", $outputPath)
