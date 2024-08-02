# Scripts

---

## Contenido

- [Scripts](#scripts)
  - [Contenido](#contenido)
  - [Scripts](#scripts-1)
    - [Massgrave.dev | Activar Windows/Office](#massgravedev--activar-windowsoffice)
    - [Massgrave.dev | Congelar prueba de Internet Download Manager](#massgravedev--congelar-prueba-de-internet-download-manager)
    - [ChrisTitusWin | Utilidades para windows](#christituswin--utilidades-para-windows)
  - [Extras](#extras)

---

## Scripts

### Massgrave.dev | Activar Windows/Office

```powershell
iex(irm https://massgrave.dev/get)
```

### Massgrave.dev | Congelar prueba de Internet Download Manager

```powershell
iex(irm https://massgrave.dev/ias)
```

### ChrisTitusWin | Utilidades para windows

> Nota: instala chocolatey.

```powershell
iex(irm christitus.com/win)
```

- Modificaciones a tener en cuenta:
  - Essential Tweaks (hay que ejecutarlas):
    - Run OO Shutup.
    - Disable Telemetry.
    - Disable Wifi-Sense.
  - Customize Preferences:
    - Bing Search in Start Menu > Disable.
    - NumLock on Startup > Enable.
    - Verbose Logon Messages > Enable.
    - Show File Extensions > Enable.

---

### Nueva instalación

- Cosas generales a hacer luego de instalar.

```powershell
$urls = @(
    "https://raw.githubusercontent.com/W4RH4WK/Debloat-Windows-10/master/scripts/remove-onedrive.ps1",
    "https://raw.githubusercontent.com/W4RH4WK/Debloat-Windows-10/master/scripts/remove-default-apps.ps1",
    "https://raw.githubusercontent.com/W4RH4WK/Debloat-Windows-10/master/scripts/optimize-windows-update.ps1",
    "https://raw.githubusercontent.com/W4RH4WK/Debloat-Windows-10/master/scripts/fix-privacy-settings.ps1",
    "https://raw.githubusercontent.com/W4RH4WK/Debloat-Windows-10/master/scripts/block-telemetry.ps1",
    "https://raw.githubusercontent.com/W4RH4WK/Debloat-Windows-10/master/utils/disable-edge-prelaunch.reg",
    "https://raw.githubusercontent.com/W4RH4WK/Debloat-Windows-10/master/utils/enable-god-mode.ps1",
    "https://raw.githubusercontent.com/W4RH4WK/Debloat-Windows-10/master/utils/enable-photo-viewer.reg",
    "https://raw.githubusercontent.com/W4RH4WK/Debloat-Windows-10/master/utils/lower-ram-usage.reg",
    "https://dl5.oo-software.com/files/ooshutup10/OOSU10.exe"
)

# Define the output directory
$outputDir = "C:\Downloads\DebloatScripts"

# Create the output directory if it doesn't exist
if (-Not (Test-Path -Path $outputDir)) {
    New-Item -ItemType Directory -Path $outputDir
}

# Function to download files
function Download-File {
    param (
        [string]$url,
        [string]$outputDir
    )
    
    $fileName = [System.IO.Path]::GetFileName($url)
    $outputPath = Join-Path -Path $outputDir -ChildPath $fileName
    
    try {
        Invoke-WebRequest -Uri $url -OutFile $outputPath
        Write-Output "Downloaded: $url to $outputPath"
    } catch {
        Write-Output "Failed to download: $url"
    }
}

# Download each file
foreach ($url in $urls) {
    Download-File -url $url -outputDir $outputDir
}

Write-Output "All downloads completed."
```

## Claves de registro

- BingSearchEnabled: false

    ```powershell
    Set-ItemProperty -Path "HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Search" -Name "BingSearchEnabled" -Value 0 -Type DWord
    ```

## Extras
