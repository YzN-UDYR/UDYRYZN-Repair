# 1. YONETICI KONTROLU (Admin Privileges)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. KARAKTER KODLAMA VE PROTOKOL
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

# 3. YAPILANDIRMA (v12.8 - Geliştirilmiş Telemetri)
$CURRENT_VER = "12.9" 
$URL_VERSION = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/version.txt"
$URL_SCRIPT  = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/UDYRYZN_DEEP_REPAIR.ps1"

$ESC = [char]27
$G = "$ESC[92m"; $B = "$ESC[94m"; $C = "$ESC[96m"; $R = "$ESC[91m"; $W = "$ESC[0m"; $Y = "$ESC[93m"; $P = "$ESC[95m"
$PAD_LOGO = "                      "
$PAD_BOX  = "        "
$PAD_TXT  = "        "
$PAD_SUB  = "               " # 15 Karakterlik hassas mühür.

$Host.UI.RawUI.WindowTitle = "UDYRYZN DEEP REPAIR v$CURRENT_VER"
Clear-Host

# 4. OTONOM GUNCELLEME MOTORU (Senin Sabit Lojigin)
try {
    $RAW_DATA = Invoke-RestMethod -Uri $URL_VERSION -UserAgent $UA -TimeoutSec 5 -UseBasicParsing
    $ONLINE_VER = ([string]$RAW_DATA).Trim() 

    if ([decimal]$ONLINE_VER -gt [decimal]$CURRENT_VER) {
        Write-Host "  $G[!] YENI SURUM TESPIT EDILDI: v$ONLINE_VER$W"
        if ((Read-Host "  Otomatik guncellensin mi? (E/H)") -eq "E") {
            $newCode = (Invoke-WebRequest -Uri $URL_SCRIPT -UserAgent $UA -UseBasicParsing).Content
            [System.IO.File]::WriteAllText($PSCommandPath, $newCode, [System.Text.Encoding]::UTF8)
            Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`""
            exit
        }
    }
} catch { }

Clear-Host
# 5. ANA LOGO
Write-Host ""
Write-Host "$C$PAD_LOGO    ██╗   ██╗██████╗ ██╗   ██╗██████╗ ██╗   ██╗███████╗███╗   ██╗"
Write-Host "$C$PAD_LOGO    ██║   ██║██╔══██╗╚██╗ ██╔╝██╔══██╗╚██╗ ██╔╝╚══███╔╝████╗  ██║"
Write-Host "$C$PAD_LOGO    ██║   ██║██║  ██║ ╚████╔╝ ██████╔╝ ╚████╔╝   ███╔╝ ██╔██╗ ██║"
Write-Host "$C$PAD_LOGO    ██║   ██║██║  ██║  ╚██╔╝  ██╔══██╗  ╚██╔╝   ███╔╝  ██║╚██╗██║"
Write-Host "$C$PAD_LOGO    ╚██████╔╝██████╔╝   ██║   ██║  ██║   ██║   ███████╗██║ ╚████║"
Write-Host "$C$PAD_LOGO     ╚═════╝ ╚═════╝    ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝$W"
Write-Host ""
Write-Host "  $B$PAD_BOX╔═══════════════════════════════════════════════════════════════════════════════════╗$W"
Write-Host "  $B$PAD_BOX║$W  $R[MODE]$W : $W Deep Repair Engine$W   $B║$W   $Y[USER]$W : $W $env:USERNAME$W      $B║$W   $Y[VER]$W : $W $CURRENT_VER.NET  $B║$W"
Write-Host "  $B$PAD_BOX╚═══════════════════════════════════════════════════════════════════════════════════╝$W"
Write-Host ""

# --- TOPLAM ILERLEME SISTEMI ---
$TOTAL_OPS = 7
$CURRENT_OP = 0
function Show-Progress {
    param($OpNum)
    $global:CURRENT_OP = $OpNum
    $percent = [math]::Round(($CURRENT_OP / $TOTAL_OPS) * 100)
    $bar = "█" * [math]::Floor($percent / 5) + "░" * (20 - [math]::Floor($percent / 5))
    Write-Host "  $B$PAD_BOX[$bar$B] $Y$percent%$W ($CURRENT_OP/$TOTAL_OPS operasyon)$W"
    Write-Host ""
}

# --- OPERASYONLAR (Tam Liste) ---

# [01] AG KATMANI SIFIRLAMA (Mikro-Raporlama)
Show-Progress 0
Write-Host "  $P$PAD_TXT[01]$W $C AG KATMANI DERIN SIFIRLAMA$W"
$netOps = @(
    @{ cmd = "netsh winsock reset"; desc = "Winsock Protokolü Sifirlama........." },
    @{ cmd = "netsh int ip reset";  desc = "IP Yapilandirmasi Sifirlama........." },
    @{ cmd = "ipconfig /release";   desc = "IP Adresi Birakma..................." },
    @{ cmd = "ipconfig /renew";     desc = "Yeni IP Adresi Aliniyor............." },
    @{ cmd = "ipconfig /flushdns";  desc = "DNS Onbelleği Temizleniyor.........." }
)
foreach ($op in $netOps) {
    Write-Host -NoNewline "$PAD_SUB $($op.desc)"
    try { Invoke-Expression $op.cmd | Out-Null; Write-Host " $G[DONE]$W" } catch { Write-Host " $R[FAIL]$W" }
}
Write-Host ""

# [02] SFC SCAN (Real-Time Precision Fix - İyileştirilmiş)
Show-Progress 1
Write-Host "  $P$PAD_TXT[02]$W $C SISTEM DOSYASI ONARIMI (SFC)$W"
Write-Host "$PAD_SUB Sistem taraması başlatılıyor..."

$sfcJob = Start-Job -ScriptBlock {
    $output = cmd /c "sfc /scannow" 2>&1
    $output
}

$lastPercent = 0
while ($sfcJob.State -eq 'Running') {
    $jobOutput = Receive-Job $sfcJob -Keep 2>&1
    if ($jobOutput) {
        $allText = $jobOutput | Out-String
        # SFC yüzde formatları: "10%" veya "10 %" 
        if ($allText -match '(\d+)\s*%') {
            $currentPercent = [int]$matches[1]
            if ($currentPercent -ne $lastPercent -and $currentPercent -le 100) {
                Write-Host -NoNewline "`r$PAD_SUB SFC Taramasi: $G$currentPercent%$W     "
                $lastPercent = $currentPercent
            }
        }
    }
    Start-Sleep -Milliseconds 500
}

# Job'ı tamamla
$null = Wait-Job $sfcJob
$null = Receive-Job $sfcJob
Remove-Job $sfcJob -Force

Write-Host "`r$PAD_SUB SFC Taramasi: $G 100% $W $G[DONE]$W                    "
Write-Host ""

# [03] DISM (Real-Time Yüzde - Geliştirilmiş)
Show-Progress 2
Write-Host "  $P$PAD_TXT[03]$W $C DISM DERIN ONARIM VE RESETBASE$W"
Write-Host "$PAD_SUB Sistem imaji onarimi baslatiliyor..."

$lastDismPercent = 0
dism /online /cleanup-image /restorehealth | ForEach-Object {
    if ($_ -match '(\d+\.\d+)%') {
        $percent = $matches[1]
        if ($percent -ne $lastDismPercent) {
            Write-Host -NoNewline "`r$PAD_SUB Onarim Durumu: $G$percent%$W     "
            $lastDismPercent = $percent
        }
    }
}
Write-Host "`r$PAD_SUB Onarim Durumu: $G 100.0% $W $G[DONE]$W                    "

Write-Host "$PAD_SUB Bilesen deposu temizleniyor (ResetBase)..."
dism /online /cleanup-image /startcomponentcleanup /resetbase | Out-Null
Write-Host "$PAD_SUB Bilesen deposu temizlendi $G[DONE]$W"
Write-Host ""

# [04] EVENT LOGS (Gerçek Zamanlı Sayaç)
Show-Progress 3
Write-Host "  $P$PAD_TXT[04]$W $C SISTEM LOGLARI TEMIZLIGI$W"
$Logs = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue
$totalLogs = $Logs.Count
$s = 0; $k = 0
$counter = 0

foreach ($Log in $Logs) {
    $counter++
    try { 
        [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($Log.LogName)
        $s++
        Write-Host -NoNewline "`r$PAD_SUB Temizlenen: $G$s/$totalLogs$W (Kilitli: $Y$k$W)     "
    }
    catch { 
        $k++
        Write-Host -NoNewline "`r$PAD_SUB Temizlenen: $G$s/$totalLogs$W (Kilitli: $Y$k$W)     "
    }
}
Write-Host "`r$PAD_SUB Temizlenen: $G$s/$totalLogs$W (Kilitli: $Y$k$W) $G[DONE]$W     "
Write-Host ""

# [05] ICON CACHE (Geliştirilmiş Hata Yönetimi)
Show-Progress 4
Write-Host "  $P$PAD_TXT[05]$W $C IKON BELLEGI RESTORASYONU$W"
try {
    Write-Host -NoNewline "$PAD_SUB Explorer durduruluyor..."
    Stop-Process -Name explorer -Force -ErrorAction Stop
    Start-Sleep -Milliseconds 500
    Write-Host "`r$PAD_SUB Explorer durduruldu $G[OK]$W          "
    
    Write-Host -NoNewline "$PAD_SUB Ikon onbellegi temizleniyor..."
    $iconFiles = Get-ChildItem "$env:localappdata\IconCache.db", "$env:localappdata\Microsoft\Windows\Explorer\iconcache_*.db" -ErrorAction SilentlyContinue
    
    if ($iconFiles) {
        $iconFiles | Remove-Item -Force -ErrorAction Stop
        Write-Host "`r$PAD_SUB Ikon onbellegi temizlendi $G[OK]$W          "
    } else {
        Write-Host "`r$PAD_SUB Ikon dosyasi bulunamadi $Y[SKIP]$W          "
    }
    
    Write-Host -NoNewline "$PAD_SUB Explorer yeniden baslatiliyor..."
    Start-Process explorer
    Start-Sleep -Milliseconds 500
    Write-Host "`r$PAD_SUB Explorer baslatildi $G[DONE]$W               "
    
} catch { 
    Write-Host "`r$PAD_SUB Hata olustu, Explorer yeniden baslatiliyor... $Y[PARTIAL]$W"
    Start-Process explorer -ErrorAction SilentlyContinue
}
Write-Host ""

# [06] USB AUTOPLAY
Show-Progress 5
Write-Host "  $P$PAD_TXT[06]$W $C USB AUTOPLAY AKTIVASYONU$W"
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Value 0 -Force
    Write-Host "$PAD_SUB USB Autoplay aktif edildi $G[DONE]$W"
} catch { 
    Write-Host "$PAD_SUB Kayit defteri erisim hatasi $Y[PARTIAL]$W" 
}
Write-Host ""

# [07] WINGET (Uygulama Bazlı Canlı Telemetri)
Show-Progress 6
Write-Host "  $P$PAD_TXT[07]$W $C SISTEM UYGULAMALARI GUNCELLEME (WINGET)$W"
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "$PAD_SUB Guncellemeler denetleniyor..."
    
    $currentApp = ""
    $isUpdating = $false
    $updateStarted = $false
    
    winget upgrade --all --silent --accept-package-agreements --accept-source-agreements 2>&1 | ForEach-Object {
        $line = $_.ToString().Trim()
        
        # Uygulama ismini yakalama (Upgrading... satırından)
        if ($line -match "Upgrading\s+(.+?)\s+\[") {
            $currentApp = $matches[1]
            $isUpdating = $true
            $updateStarted = $true
            Write-Host -NoNewline "`r$PAD_SUB $C$currentApp$W Guncelleniyor...                              "
        }
        # Yüzdelik gösterge yakalama
        elseif ($line -match "(\d+)%" -and $isUpdating) {
            $percent = $matches[1]
            Write-Host -NoNewline "`r$PAD_SUB $C$currentApp$W Guncelleniyor: $Y$percent%$W               "
        }
        # Yükleniyor durumu
        elseif ($line -match "Installing" -and $isUpdating) {
            Write-Host -NoNewline "`r$PAD_SUB $C$currentApp$W Yukleniyor...                                "
        }
        # Başarıyla tamamlandı
        elseif ($line -match "(Successfully installed|successfully upgraded)" -and $isUpdating) {
            Write-Host "`r$PAD_SUB $C$currentApp$W Guncellendi $G[DONE]$W                                          "
            $isUpdating = $false
            $currentApp = ""
        }
    }
    
    # Eğer hiç güncelleme yapılmadıysa
    if (-not $updateStarted) {
        Write-Host "$PAD_SUB Tum uygulamalar guncel $G[DONE]$W"
    }
    
} else { 
    Write-Host "$PAD_SUB Winget bulunamadi $R[FAIL]$W" 
}
Write-Host ""

# KAPANIS - Tam İlerleme
Show-Progress 7
Write-Host ""
Write-Host "  $B$PAD_BOX" + ("═" * 80)
Write-Host "  $G                           TUM OPERASYONLAR TAMAMLANDI."
Write-Host "  $B$PAD_BOX" + ("═" * 80) + "$W"
Write-Host ""
Read-Host "Pencereyi kapatmak için Enter'a basınız..."
