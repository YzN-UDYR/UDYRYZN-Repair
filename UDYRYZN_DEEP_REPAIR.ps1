# 1. YONETICI KONTROLU (Admin Privileges)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. KARAKTER KODLAMA VE PROTOKOL (Otomatik Karakter Muhurleme)
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

# 3. YAPILANDIRMA (v11.9 Precision)
$CURRENT_VER = "11.9" 
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

# 4. AKILLI GUNCELLEME MOTORU (Tam 2 Saniye Limitli & Version Casting)
Write-Host "  $Y[*] Guncelleme sunucusu sorgulaniyor (2sn limit)...$W"
try {
    # [version] tipi [decimal]'a gore cok daha guvenlidir (Nokta/Virgul hatasi yapmaz)
    $RAW_DATA = Invoke-RestMethod -Uri $URL_VERSION -UserAgent $UA -TimeoutSec 2 -UseBasicParsing
    $ONLINE_VER = [version]($RAW_DATA.Trim())
    $LOCAL_VER  = [version]$CURRENT_VER

    if ($ONLINE_VER -gt $LOCAL_VER) {
        Write-Host "  $G[!] YENI SURUM TESPIT EDILDI: v$ONLINE_VER$W"
        $choice = Read-Host "  Otomatik guncellensin mi? (E/H)"
        if ($choice -eq "E" -or $choice -eq "e") {
            $newCode = (Invoke-WebRequest -Uri $URL_SCRIPT -UserAgent $UA -UseBasicParsing).Content
            [System.IO.File]::WriteAllText($PSCommandPath, $newCode, [System.Text.Encoding]::UTF8)
            Write-Host "  $G[+] Basariyla guncellendi. Lutfen tekrar baslatin.$W"; Pause; exit
        }
    } else {
        Write-Host "  $G[+] Yazilim guncel. Operasyon basliyor...$W"
        Start-Sleep -Seconds 1
    }
} catch { Write-Host "  $R[-] Guncelleme hatti mesgul veya baglanti yok, atlandi.$W" }

Clear-Host
# 5. ANA LOGO (v8.3 Mirasi)
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
    netsh winsock reset | Out-Null; netsh int ip reset | Out-Null; ipconfig /flushdns | Out-Null
    Write-Host "$PAD_SUB $G[DONE]$W"
} catch { Write-Host "$PAD_SUB $Y[PARTIAL]$W" }
Write-Host ""

# [02] SFC SCAN (In-Place Update)
Write-Host "  $P$PAD_TXT[02]$W $C SISTEM DOSYASI ONARIMI (SFC)$W"
Write-Host "$PAD_SUB Beginning system scan. Please wait..."
sfc /scannow | ForEach-Object {
    if ($_ -match "(\d+%)") {
        # Yuzdelik kismi ayiklayip ayni satirda gunceller
        Write-Host -NoNewline "`r$PAD_SUB Onarim Durumu: $($matches[1])"
    }
}
Write-Host "`n$PAD_SUB $G[DONE]$W Tarama basariyla sonuclandi."
Write-Host ""

# [03] DISM (In-Place Update & Hashtable Fix)
Write-Host "  $P$PAD_TXT[03]$W $C DISM DERIN ONARIM VE RESETBASE$W"
Write-Host "$PAD_SUB Deployment Image Servicing is active..."
dism /online /cleanup-image /restorehealth | ForEach-Object {
    if ($_ -match "(\d+\.\d+%)") {
        # Hashtable hatasini $(...) sub-expression ile cozuyoruz
        Write-Host -NoNewline "`r$PAD_SUB Guncelleme: $($matches[1])"
    }
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
Write-Host "$PAD_SUB $Y[STATUS]$W ($s basarili, $k kilitli atlandi)"
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

# KAPANIS
Write-Host ""
Write-Host "  $B$PAD_BOX" + ("═" * 80)
Write-Host "  $G                                OPERASYON TAMAMLANDI."
Write-Host "  $B$PAD_BOX" + ("═" * 80) + "$W"
Read-Host "Kapatmak için Enter'a basınız..."
