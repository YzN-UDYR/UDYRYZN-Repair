# 1. YONETICI KONTROLU (Privilege Escalation)
if (-not ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)) {
    Start-Process powershell -ArgumentList "-NoProfile -ExecutionPolicy Bypass -File `"$PSCommandPath`"" -Verb RunAs
    exit
}

# 2. KARAKTER KODLAMA VE PROTOKOL SABITLEME (Gorsel ve Baglanti Cozumu)
# Ekranda â gibi garip karakterler cikmamasi icin UTF8 zorunludur.
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
$UA = "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"

# 3. YAPILANDIRMA (Kritik: Bu rakam GitHub'daki version.txt ile ESLESMEK ZORUNDA)
$CURRENT_VER = "11.0" 
$URL_VERSION = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/version.txt"
$URL_SCRIPT  = "https://raw.githubusercontent.com/YzN-UDYR/UDYRYZN-Repair/main/UDYRYZN_DEEP_REPAIR.ps1"

$ESC = [char]27
$G = "$ESC[92m"; $B = "$ESC[94m"; $C = "$ESC[96m"; $R = "$ESC[91m"; $W = "$ESC[0m"; $Y = "$ESC[93m"; $P = "$ESC[95m"
$PAD_LOGO = "                      "
$PAD_BOX  = "        "
$PAD_TXT  = "        "

$Host.UI.RawUI.WindowTitle = "UDYRYZN DEEP REPAIR v$CURRENT_VER"
Clear-Host

# 4. AKILLI GUNCELLEME VE DONGU KIRICI (Self-Overwriting)
Write-Host "  $Y[*] Guncelleme ajani ve TLS 1.2 baglantisi kuruluyor...$W"
try {
    $RAW_DATA = Invoke-RestMethod -Uri $URL_VERSION -UserAgent $UA -TimeoutSec 5
    $ONLINE_VER = ([string]$RAW_DATA).Trim() 

    if ([decimal]$ONLINE_VER -gt [decimal]$CURRENT_VER) {
        Write-Host "  $G[!] YENI SURUM MEVCUT: v$ONLINE_VER$W"
        $choice = Read-Host "  Otomatik guncellensin mi? (E/H)"
        if ($choice -eq "E" -or $choice -eq "e") {
            Write-Host "  $C[*] Yeni surum indiriliyor ve dosya guncelleniyor...$W"
            Invoke-WebRequest -Uri $URL_SCRIPT -OutFile $PSCommandPath -UserAgent $UA 
            Write-Host "  $G[+] Basarili! Lutfen bu pencereyi kapatin ve scripti tekrar acin.$W"
            Pause; exit
        }
    } else {
        Write-Host "  $G[+] Yazilim guncel. (v$CURRENT_VER)$W"
        Start-Sleep -Seconds 1
    }
} catch {
    Write-Host "  $R[-] Sunucu baglantisi basarisiz. Cevrimdisi modda devam ediliyor...$W"
    Start-Sleep -Seconds 2
}

Clear-Host
# 5. ANA LOGO VE TANITIM KUTUSU (Geri Getirilen v8.3 Tasarimi)
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
Write-Host ""
Write-Host "  $R$PAD_TXT  [!] DIKKAT: BU ISLEM DERIN ONARIM ICERDIGI ICIN UZUN SUREBILIR.$W"
Write-Host "  $R$PAD_TXT  [!] LUTFEN PENCEREYI KAPATMAYIN VE ISLEMIN BITMESINI BEKLEYIN.$W"
Write-Host ""

# --- OPERASYONLAR (v8.3 Bat'tan Eksiksiz Aktarilanlar) ---

# [01] AG SIFIRLAMA
Write-Host "  $P$PAD_TXT[01]$W $C AG KATMANI DERIN SIFIRLAMA$W"
netsh winsock reset | Out-Null; netsh int ip reset | Out-Null
ipconfig /release | Out-Null; ipconfig /renew | Out-Null; ipconfig /flushdns | Out-Null
Write-Host "  $G$PAD_TXT [DONE]$W Ag yapilandirmasi sifirlandi."
Write-Host ""

# [02] SFC ONARIMI
Write-Host "  $P$PAD_TXT[02]$W $C SISTEM DOSYASI ONARIMI (SFC)$W"
sfc /scannow
Write-Host ""

# [03] DISM (RestoreHealth + ResetBase)
Write-Host "  $P$PAD_TXT[03]$W $C DISM DERIN ONARIM VE RESETBASE$W"
dism /online /cleanup-image /restorehealth
dism /online /cleanup-image /startcomponentcleanup /resetbase | Out-Null
Write-Host "  $G$PAD_TXT [DONE]$W Bilesen deposu tertemiz."
Write-Host ""

# [04] EVENT LOGS
Write-Host "  $P$PAD_TXT[04]$W $C SISTEM LOGLARI TEMIZLIGI$W"
Get-WinEvent -ListLog * -ErrorAction SilentlyContinue | ForEach-Object { [System.Diagnostics.Eventing.Reader.EventLogSession]::GlobalSession.ClearLog($_.LogName) }
Write-Host "  $G$PAD_TXT [DONE]$W Olay gunlukleri sifirlandi."
Write-Host ""

# [05] ICON CACHE REBUILD
Write-Host "  $P$PAD_TXT[05]$W $C IKON BELLEGI RESTORASYONU$W"
Stop-Process -Name explorer -Force -ErrorAction SilentlyContinue
Remove-Item "$env:localappdata\IconCache.db", "$env:localappdata\Microsoft\Windows\Explorer\iconcache_*.db" -Force -ErrorAction SilentlyContinue
Start-Process explorer
Write-Host "  $G$PAD_TXT [DONE]$W Ikon cache ve Explorer yenilendi."
Write-Host ""

# [06] USB AUTOPLAY AKTIVASYONU
Write-Host "  $P$PAD_TXT[06]$W $C USB VE MEDYA AUTOPLAY AKTIVASYONU$W"
Set-ItemProperty -Path "HKCU:\Software\Microsoft\Windows\CurrentVersion\Explorer\AutoplayHandlers" -Name "DisableAutoplay" -Value 0 -Force
Write-Host "  $G$PAD_TXT [DONE]$W USB suruculeri artik otomatik acilacak."
Write-Host ""

# KAPANIS
Write-Host "  $B$PAD_BOX" + ("═" * 80)
Write-Host "  $G                                OPERASYON TAMAMLANDI."
Write-Host "  $B$PAD_BOX" + ("═" * 80) + "$W"
Write-Host ""
Read-Host "Kapatmak icin Enter'a basiniz..."
