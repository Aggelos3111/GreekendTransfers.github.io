Param(
  [string]$ProjectPath = "c:\Users\aggel\OneDrive\Desktop\Projects\Spiros Travels Website",
  [int[]]$Widths = @(800,1200,1600,1920)
)

$ErrorActionPreference = 'Stop'

$imgDir = Join-Path $ProjectPath 'images'
$outDir = Join-Path $imgDir 'optimized'
New-Item -ItemType Directory -Force -Path $outDir | Out-Null

$skip = @(
  'Peugeot 508.png','Toyota Proace.png','Logo.png'
)

Add-Type -AssemblyName System.Drawing

function Get-JpegCodec {
  $codecs = [System.Drawing.Imaging.ImageCodecInfo]::GetImageEncoders()
  return ($codecs | Where-Object { $_.MimeType -eq 'image/jpeg' })
}

function Save-ResizedImage([System.Drawing.Image]$image, [string]$outPath, [int]$targetWidth, [string]$format) {
  
  if ($image.Width -le $targetWidth) { return $false }

  $ratio = $image.Height / [double]$image.Width
  $newWidth = $targetWidth
  $newHeight = [int][Math]::Round($newWidth * $ratio)

  $bmp = New-Object System.Drawing.Bitmap $newWidth, $newHeight
  $gfx = [System.Drawing.Graphics]::FromImage($bmp)
  $gfx.CompositingQuality = 'HighQuality'
  $gfx.InterpolationMode = 'HighQualityBicubic'
  $gfx.SmoothingMode = 'HighQuality'
  $gfx.PixelOffsetMode = 'HighQuality'
  $gfx.DrawImage($image, 0, 0, $newWidth, $newHeight)

  try {
    if ($format -eq 'png') {
      $bmp.Save($outPath, [System.Drawing.Imaging.ImageFormat]::Png)
    } else {
      $codec = Get-JpegCodec
      $encParams = New-Object System.Drawing.Imaging.EncoderParameters 1
      $qualityEncoder = [System.Drawing.Imaging.Encoder]::Quality
      $qualityParam = New-Object System.Drawing.Imaging.EncoderParameter $qualityEncoder, 82
      $encParams.Param[0] = $qualityParam
      $bmp.Save($outPath, $codec, $encParams)
      $encParams.Dispose()
    }
  } finally {
    $gfx.Dispose()
    $bmp.Dispose()
  }
  return $true
}

$extensions = @('*.jpg','*.jpeg','*.jfif','*.png')
$files = Get-ChildItem -Path $imgDir -File -Include $extensions -Recurse | Where-Object { $skip -notcontains $_.Name }

Write-Host ("Found {0} images to process" -f $files.Count)

foreach ($f in $files) {
  try {
    $img = [System.Drawing.Image]::FromFile($f.FullName)
  } catch {
    Write-Warning ("Skipping unreadable image: {0}" -f $f.FullName)
    continue
  }
  try {
    $name = [IO.Path]::GetFileNameWithoutExtension($f.Name)
    $ext  = $f.Extension.ToLower()
    $isPng = ($ext -eq '.png')
    $outExt = if ($isPng) { '.png' } else { '.jpg' }

    foreach ($w in $Widths) {
      $outPath = Join-Path $outDir ("${name}-${w}${outExt}")
      if (Test-Path $outPath) { continue }
      $changed = Save-ResizedImage -image $img -outPath $outPath -targetWidth $w -format (if($isPng){'png'}else{'jpg'})
      if ($changed) { Write-Host ("Created: {0}" -f $outPath) }
    }
  } finally {
    $img.Dispose()
  }
}

Write-Host 'Done. Generated responsive variants in images/optimized.'
