# 1. YONETICI KONTROLU (Admin Privileges)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. KARAKTER VE PROTOKOL SABITLEME
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

# 3. YAPILANDIRMA (v12.1 Precision)
$CURRENT_VER = "12.0" 
$URL_VERSION = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/version.txt"
$URL_SCRIPT  = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/UDYRYZN_DEEP_REPAIR.ps1"

$ESC = [char]27
$G = "$ESC[92m"; $B = "$ESC[94m"; $C = "$ESC[96m"; $R = "$ESC[91m"; $W = "$ESC[0m"; $Y = "$ESC[93m"; $P = "$ESC[95m"
$PAD_LOGO = "                      "
$PAD_BOX  = "        "
$PAD_TXT  = "        "
$PAD_SUB  = "               " # 15 Karakter: Operasyon basliginin tam alti.

$Host.UI.RawUI.WindowTitle = "UDYRYZN DEEP REPAIR v$CURRENT_VER"
Clear-Host

# 4. AKILLI GUNCELLEME MOTORU (5 Saniye Tolerans)
Write-Host "  $Y[*] Guncelleme kanali sorgulaniyor (5sn limit)...$W"
try {
    $ONLINE_RAW = (Invoke-RestMethod -Uri $URL_VERSION -UserAgent $UA -TimeoutSec 5 -UseBasicParsing).Trim()
    $ONLINE_VER = [version]$ONLINE_RAW
    $LOCAL_VER  = [version]$CURRENT_VER

    if ($ONLINE_VER -gt $LOCAL_VER) {
        Write-Host "  $G[!] YENI SURUM BULUNDU: v$ONLINE_VER$W"
        $choice = Read-Host "  Otomatik guncellensin mi? (E/H)"
        if ($choice -eq "E" -or $choice -eq "e") {
            $newCode = (Invoke-WebRequest -Uri $URL_SCRIPT -UserAgent $UA -UseBasicParsing).Content
            [System.IO.File]::WriteAllText($PSCommandPath, $newCode, [System.Text.Encoding]::UTF8)
            Write-Host "  $G[+] Basariyla guncellendi. Lutfen tekrar baslatin.$W"
            Read-Host "Devam etmek icin Enter'a basınız..."; exit
        }
    }
} catch { Write-Host "  $R[-] Guncelleme hatti su an mesgul, atlandi.$W" }

Clear-Host
# 5. ANA LOGO (v8.3 Tasarimi)
Write-Host ""
Write-Host "$C$PAD_LOGO    ██╗   ██╗██████╗ ██╗   ██╗██████╗ ██╗   ██╗███████╗███╗   ██╗"
Write-Host "$C$PAD_LOGO    ██║   ██║██╔══██╗╚██╗ ██╔╝██╔══██╗╚██╗ ██╔╝╚══███╔╝████╗  ██║"
Write-Host "$C$PAD_LOGO    ██║   ██║██║  ██║ ╚████╔╝ ██████╔╝ ╚████╔╝   ███╔╝ ██╔██╗ ██║"
Write-Host "$C$PAD_LOGO    ██║   ██║██║  ██║  ╚██╔╝  ██╔══██╗  ╚██╔╝   ███╔╝  ██║╚██╗██║"
Write-Host "$C$PAD_LOGO    ╚██████╔╝██████╔╝   ██║   ██║  ██║   ██║   ███████╗██║ ╚████║"
Write-Host "$C$PAD_LOGO     ╚═════╝ ╚═════╝   ╚═╝   ╚═╝  ╚═╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝$W"
Write-Host ""
Write-Host "  $B$PAD_BOX╔══════════════════════════════════════════════════════════════════════════════════╗$W"
Write-Host "  $B$PAD_BOX║$W  $R[MODE]$W : $W Deep Repair Engine$W   $B║$W   $Y[USER]$W : $W $env:USERNAME$W      $B║$W   $Y[VER]$W : $W $CURRENT_VER.NET  $B║$W"
Write-Host "  $B$PAD_BOX╚══════════════════════════════════════════════════════════════════════════════════╝$W"

# --- OPERASYONLAR ---

# [01] NETWORK RESET
Write-Host "  $P$PAD_TXT[01]$W $C AG KATMANI DERIN SIFIRLAMA$W"
try {
    netsh winsock reset | Out-Null; netsh int ip reset | Out-Null; ipconfig /release | Out-Null; ipconfig /renew | Out-Null; ipconfig /flushdns | Out-Null
    Write-Host "$PAD_SUB $G[DONE]$W"
} catch { Write-Host "$PAD_SUB $Y[PARTIAL]$W" }
Write-Host ""

# [02] SFC SCAN (Dinamik Yuzde Guncelleme)
Write-Host "  $P$PAD_TXT[02]$W $C SISTEM ONARIMI (SFC)$W"
Write-Host "$PAD_SUB Sistem taramasi baslatiliyor..."
sfc /scannow | ForEach-Object {
    if ($_ -match "(\d+%)") {
        # Yuzdeyi yakalayip ayni satirda gunceller (Vertical Spam Onleyici)
        Write-Host -NoNewline "`r$PAD_SUB Ilerleme Durumu: $($matches[1])"
    }
}
Write-Host "`n$PAD_SUB $G[DONE]$W"
Write-Host ""

# [03] DISM (Hashtable Fix & Dinamik Yuzde)
Write-Host "  $P$PAD_TXT[03]$W $C DISM DERIN ONARIM VE RESETBASE$W"
dism /online /cleanup-image /restorehealth | ForEach-Object {
    if ($_ -match "(\d+\.\d+%)") {
        # System.Collections.Hashtable hatasi sub-expression ile giderildi
        Write-Host -NoNewline "`r$PAD_SUB Onarim Durumu: $($matches[1])"
    }
}
Write-Host "`n$PAD_SUB Bilesen deposu temizleniyor (ResetBase)..."
dism /online /cleanup-image /startcomponentcleanup /resetbase | Out-Null
Write-Host "$PAD_SUB $G[DONE]$W"
Write-Host ""

# [04] EVENT LOGS (Smart Feedback)
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

# KAPANIS (PAUSE GARANTISI)
Write-Host ""
Write-Host "  $B$PAD_BOX" + ("═" * 80)
Write-Host "  $G                                OPERASYON TAMAMLANDI."
Write-Host "  $B$PAD_BOX" + ("═" * 80) + "$W"
Write-Host ""
Read-Host "Pencereyi kapatmak için Enter'a basınız..."
