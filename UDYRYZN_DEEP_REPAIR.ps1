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

# 3. YAPILANDIRMA (v12.6 - Sürüm Mühürlendi)
$CURRENT_VER = "12.7" 
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

# --- OPERASYONLAR (Tam Liste) ---

# [01] AG KATMANI SIFIRLAMA (Mikro-Raporlama)
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

# [02] SFC SCAN (Real-Time Precision Fix)
Write-Host "  $P$PAD_TXT[02]$W $C SISTEM DOSYASI ONARIMI (SFC)$W"
Write-Host "$PAD_SUB Sistem taraması yapılıyor..."
$sfcProc = Start-Process cmd -ArgumentList "/c sfc /scannow" -NoNewWindow -PassThru -RedirectStandardOutput "sfc_telemetry.log"
while (!$sfcProc.HasExited) {
    if (Test-Path "sfc_telemetry.log") {
        $content = Get-Content "sfc_telemetry.log" -Tail 1 -ErrorAction SilentlyContinue
        if ($content -match "(\d+%)") {
            Write-Host -NoNewline "`r$PAD_SUB SFC Taramasi: $G$($matches[1])$W"
        }
    }
    Start-Sleep -Milliseconds 300
}
Write-Host "`r$PAD_SUB SFC Taramasi: $G 100% $W $G[DONE]$W"
Write-Host ""
Remove-Item "sfc_telemetry.log" -ErrorAction SilentlyContinue

# [03] DISM (Real-Time Yüzde)
Write-Host "  $P$PAD_TXT[03]$W $C DISM DERIN ONARIM VE RESETBASE$W"
dism /online /cleanup-image /restorehealth | ForEach-Object {
    if ($_ -match "(\d+\.\d+%)") { Write-Host -NoNewline "`r$PAD_SUB Onarim Durumu: $G$($matches[1])$W" }
}
Write-Host "`n$PAD_SUB Bilesen deposu temizleniyor (ResetBase)..."
dism /online /cleanup-image /startcomponentcleanup /resetbase | Out-Null
Write-Host "$PAD_SUB $G[DONE]$W"
Write-Host ""

# [04] EVENT LOGS
Write-Host "  $P$PAD_TXT[04]$W $C SISTEM LOGLARI TEMIZLIGI$W"
$Logs = Get-WinEvent -ListLog * -ErrorAction SilentlyContinue
$s = 0; $k = 0
foreach ($Log in $Logs) {
    try { [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($Log.LogName); $s++ }
    catch { $k++ }
}
Write-Host "$PAD_SUB $Y[STATUS]$W ($s basarili, $k kilitli gunluk atlandi)"
Write-Host ""

# [05] ICON CACHE
Write-Host "  $P$PAD_TXT[05]$W $C IKON BELLEGI RESTORASYONU$W"
try {
    Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
    $f = Get-ChildItem "$env:localappdata\IconCache.db", "$env:localappdata\Microsoft\Windows\Explorer\iconcache_*.db" -ErrorAction SilentlyContinue
    $f | Remove-Item -Force -ErrorAction SilentlyContinue
    Start-Process explorer; Write-Host "$PAD_SUB $G[DONE]$W"
} catch { Start-Process explorer }
Write-Host ""

# [06] USB AUTOPLAY
Write-Host "  $P$PAD_TXT[06]$W $C USB AUTOPLAY AKTIVASYONU$W"
try {
    Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Value 0 -Force
    Write-Host "$PAD_SUB $G[DONE]$W"
} catch { Write-Host "$PAD_SUB $Y[PARTIAL]$W" }
Write-Host ""

# [07] WINGET (Uygulama Bazlı Canlı Telemetri)
Write-Host "  $P$PAD_TXT[07]$W $C SISTEM UYGULAMALARI GUNCELLEME (WINGET)$W"
if (Get-Command winget -ErrorAction SilentlyContinue) {
    Write-Host "$PAD_SUB Guncellemeler denetleniyor..."
    $currentApp = "Sistem"
    winget upgrade --all --silent --accept-package-agreements --accept-source-agreements | ForEach-Object {
        $line = $_.Trim()
        if ($line -match "^([\w\.\-]+)\s+.*$") { $currentApp = $matches[1] }
        if ($line -match "(\d+%)") {
            Write-Host -NoNewline "`r$PAD_SUB $P$currentApp$W being updated $Y$($matches[1])$W"
        }
        elseif ($line -match "Successfully installed") {
            Write-Host "`n$PAD_SUB $P$currentApp$W Successfully Updated $G[DONE]$W"
        }
    }
} else { Write-Host "$PAD_SUB $R[FAIL]$W Winget bulunamadi." }

# KAPANIS (PAUSE GARANTISI)
Write-Host ""
Write-Host "  $B$PAD_BOX" + ("═" * 80)
Write-Host "  $G                                OPERASYON TAMAMLANDI."
Write-Host "  $B$PAD_BOX" + ("═" * 80) + "$W"
Write-Host ""
Read-Host "Pencereyi kapatmak için Enter'a basınız..."

